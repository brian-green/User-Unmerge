# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repo contains a standalone Python script for migrating Zendesk tickets from one user to another.

## Python Script (`user_unmerge.py`)

The script uses the `requests` library. Configuration is done by editing constants at the top of the file:
- `url` — Zendesk API endpoint with the source user's ID
- `user` — Zendesk email + `/token`
- `token` — Zendesk API token
- `TARGET_USER_ID_INT` — integer ID of the destination user

Run with: `python user_unmerge.py`
