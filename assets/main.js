(function () {
  var client = ZAFClient.init();

  var state = {
    userId: null,
    tickets: [],
    selectedTicketIds: new Set()
  };

  // DOM references
  var els = {
    userName: document.getElementById('user-name'),
    userEmail: document.getElementById('user-email'),
    loading: document.getElementById('loading'),
    ticketList: document.getElementById('ticket-list'),
    tickets: document.getElementById('tickets'),
    ticketCount: document.getElementById('ticket-count'),
    noTickets: document.getElementById('no-tickets'),
    selectAll: document.getElementById('select-all'),
    unmergeSection: document.getElementById('unmerge-section'),
    targetUserId: document.getElementById('target-user-id'),
    unmergeBtn: document.getElementById('unmerge-btn'),
    progressSection: document.getElementById('progress-section'),
    progressBar: document.getElementById('progress-bar'),
    progressText: document.getElementById('progress-text'),
    log: document.getElementById('log'),
    error: document.getElementById('error')
  };

  client.on('app.registered', function () {
    init();
  });

  function init() {
    client.get('user').then(function (data) {
      var user = data.user;
      state.userId = user.id;
      els.userName.textContent = user.name;
      els.userEmail.textContent = user.email || '';
      fetchTickets();
    }).catch(function (err) {
      showError('Failed to load user data: ' + err.message);
    });
  }

  // Fetch all requested tickets for the current user with pagination
  function fetchTickets() {
    els.loading.classList.remove('hidden');
    var allTickets = [];

    function fetchPage(url) {
      return client.request({ url: url, type: 'GET' }).then(function (data) {
        allTickets = allTickets.concat(data.tickets);
        if (data.next_page) {
          return fetchPage(data.next_page);
        }
        return allTickets;
      });
    }

    fetchPage('/api/v2/users/' + state.userId + '/tickets/requested.json')
      .then(function (tickets) {
        state.tickets = tickets;
        renderTickets();
      })
      .catch(function (err) {
        showError('Failed to load tickets: ' + err.message);
      })
      .finally(function () {
        els.loading.classList.add('hidden');
      });
  }

  function renderTickets() {
    if (state.tickets.length === 0) {
      els.noTickets.classList.remove('hidden');
      return;
    }

    els.tickets.innerHTML = '';
    state.tickets.forEach(function (ticket) {
      var li = document.createElement('li');
      var checkbox = document.createElement('input');
      checkbox.type = 'checkbox';
      checkbox.dataset.ticketId = ticket.id;
      checkbox.addEventListener('change', onTicketCheckboxChange);

      var idSpan = document.createElement('span');
      idSpan.className = 'ticket-id';
      idSpan.textContent = '#' + ticket.id;

      var subjectSpan = document.createElement('span');
      subjectSpan.className = 'ticket-subject';
      subjectSpan.textContent = ticket.subject || '(no subject)';
      subjectSpan.title = ticket.subject || '';

      var statusSpan = document.createElement('span');
      statusSpan.className = 'ticket-status ' + (ticket.status || '');
      statusSpan.textContent = ticket.status || '';

      li.appendChild(checkbox);
      li.appendChild(idSpan);
      li.appendChild(subjectSpan);
      li.appendChild(statusSpan);
      els.tickets.appendChild(li);
    });

    els.ticketCount.textContent = state.tickets.length + ' ticket' + (state.tickets.length !== 1 ? 's' : '');
    els.ticketList.classList.remove('hidden');
    els.unmergeSection.classList.remove('hidden');
    updateUnmergeButton();
  }

  function onTicketCheckboxChange(e) {
    var id = Number(e.target.dataset.ticketId);
    if (e.target.checked) {
      state.selectedTicketIds.add(id);
    } else {
      state.selectedTicketIds.delete(id);
    }
    els.selectAll.checked = state.selectedTicketIds.size === state.tickets.length;
    updateUnmergeButton();
  }

  els.selectAll.addEventListener('change', function () {
    var checked = els.selectAll.checked;
    var checkboxes = els.tickets.querySelectorAll('input[type="checkbox"]');
    checkboxes.forEach(function (cb) {
      cb.checked = checked;
      var id = Number(cb.dataset.ticketId);
      if (checked) {
        state.selectedTicketIds.add(id);
      } else {
        state.selectedTicketIds.delete(id);
      }
    });
    updateUnmergeButton();
  });

  els.targetUserId.addEventListener('input', updateUnmergeButton);

  function updateUnmergeButton() {
    var hasSelection = state.selectedTicketIds.size > 0;
    var hasTarget = els.targetUserId.value.trim() !== '';
    els.unmergeBtn.disabled = !(hasSelection && hasTarget);
  }

  els.unmergeBtn.addEventListener('click', function () {
    var targetId = Number(els.targetUserId.value.trim());
    if (!targetId || targetId === state.userId) {
      showError('Please enter a valid target user ID that differs from the current user.');
      return;
    }
    startUnmerge(targetId);
  });

  function startUnmerge(targetUserId) {
    var ticketIds = Array.from(state.selectedTicketIds);
    var total = ticketIds.length;
    var processed = 0;
    var succeeded = 0;
    var failed = 0;

    // Lock UI
    els.unmergeBtn.disabled = true;
    els.targetUserId.disabled = true;
    els.progressSection.classList.remove('hidden');
    els.log.innerHTML = '';
    els.error.classList.add('hidden');
    logMessage('Starting unmerge of ' + total + ' ticket(s) to user ' + targetUserId, 'info');

    function processNext() {
      if (processed >= total) {
        logMessage('Done. ' + succeeded + ' succeeded, ' + failed + ' failed.', succeeded === total ? 'success' : 'error');
        els.unmergeBtn.disabled = false;
        els.targetUserId.disabled = false;
        return;
      }

      var ticketId = ticketIds[processed];
      logMessage('Processing ticket #' + ticketId + '...', 'info');

      // Step 1: Get ticket data
      client.request({ url: '/api/v2/tickets/' + ticketId + '.json', type: 'GET' })
        .then(function (ticketData) {
          var ticket = ticketData.ticket;

          // Remove satisfaction fields that block import
          delete ticket.satisfaction_probability;
          delete ticket.satisfaction_rating;

          // Reassign to target user
          ticket.requester_id = targetUserId;

          // Step 2: Get ticket comments
          return fetchAllComments(ticketId).then(function (comments) {
            return { ticket: ticket, comments: comments };
          });
        })
        .then(function (payload) {
          // Step 3: Import ticket under new user
          var importPayload = {
            ticket: payload.ticket
          };
          importPayload.ticket.comments = payload.comments;

          return client.request({
            url: '/api/v2/imports/tickets.json',
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify(importPayload)
          });
        })
        .then(function () {
          succeeded++;
          logMessage('Ticket #' + ticketId + ' imported successfully.', 'success');
        })
        .catch(function (err) {
          failed++;
          var detail = '';
          if (err.responseText) {
            try { detail = ': ' + JSON.parse(err.responseText).error; } catch (e) { detail = ': ' + err.responseText; }
          } else if (err.message) {
            detail = ': ' + err.message;
          }
          logMessage('Ticket #' + ticketId + ' failed' + detail, 'error');
        })
        .finally(function () {
          processed++;
          var pct = Math.round((processed / total) * 100);
          els.progressBar.style.width = pct + '%';
          els.progressText.textContent = processed + ' / ' + total + ' processed';
          processNext();
        });
    }

    processNext();
  }

  // Fetch all comments for a ticket, handling pagination
  function fetchAllComments(ticketId) {
    var allComments = [];

    function fetchPage(url) {
      return client.request({ url: url, type: 'GET' }).then(function (data) {
        allComments = allComments.concat(data.comments);
        if (data.next_page) {
          return fetchPage(data.next_page);
        }
        return allComments;
      });
    }

    return fetchPage('/api/v2/tickets/' + ticketId + '/comments.json');
  }

  function logMessage(msg, type) {
    var div = document.createElement('div');
    div.className = 'log-entry ' + (type || 'info');
    div.textContent = msg;
    els.log.appendChild(div);
    els.log.scrollTop = els.log.scrollHeight;
  }

  function showError(msg) {
    els.error.textContent = msg;
    els.error.classList.remove('hidden');
  }
})();
