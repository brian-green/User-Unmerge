# Import modules
import requests
import json

# Authentication Data and Routes
url = 'https://SUBDOMAIN.zendesk.com/api/v2/users/SOURCE-USER-ID/tickets/requested.json'
user = 'agiron@vormetric.com/token'
token = 'TOKEN'

print('Creating the Session')
s = requests.Session()
s.auth = (user, token)
s.headers = {'Content-Type':'application/json'}

print('Craeting the list of ticket to process')
ticket_list = []

while url:
    response = s.get(url)
    data = response.json()
    for ticket in data['tickets']:
        ticket_id_string = ticket['id']
        ticket_list.append(ticket['id'])
    url = data['next_page']

print('Done making ticket list.')

print('Making function')

def repost(list):
    for ticket_id in ticket_list:
        
        print('Getting ticket data')
        ticket_data = s.get('https://SUBDOMAIN.zendesk.com/api/v2/tickets/' + str(ticket_id) + '.json')
        
        ticket_data = ticket_data.json()
        
        print('Modifying ticket data')
        del ticket_data['ticket']['satisfaction_probability']
        del ticket_data['ticket']['satisfaction_rating']
        ticket_data['ticket']['requester_id'] = TARGET_USER_ID_INT
        
        print('Getting comments')
        comment_data = s.get('https://SUBDOMAIN.zendesk.com/api/v2/tickets/' + str(ticket_id) + '/comments.json')
        comment_data = comment_data.json()
        comments = comment_data['comments']
        
        print('Making final payload')
        ticket_data['comments'] = comments
        ticket_data = json.dumps(ticket_data)

        post = s.post('https://SUBDOMAIN.zendesk.com/api/v2/imports/tickets.json', data = ticket_data)
        
        if post.status_code == 201:
            print("Posted ticket #" + str(ticket_id))
        else:
            print("bad post")
            print(post.status_code)
            print(post.headers)
            print(post.text)
            print("-===========-")
            print(json.dumps(ticket_data))
            break

repost(ticket_list)
