# certmorebot

Simple wrapper script for LetsEncrypt `certbot`,
managing a local certificate store,
for domains using AWS Route 53 or other DNS services.

- Requires Docker (but data is stored outside of it).
- Run as root.

## Setup

- This directory will be referred to as `/app`.
- Create a data directory somewhere else, e.g. `~/certs`.
- Copy `app/sample-config.sh` to `~/certs/config.sh` and edit it.

## Usage

- cd `~/certs`
- Add cert for a domain: `sudo /app/certmorebot.sh add '*.cooldomain.org'`.
- Automatic renewals: set a daily cron job for `sudo /app/certmorebot.sh renew`.
- After adding or renewing, certmorebot will also concat  
  `~/certs/letsencrypt/live/*/fullchain.pem` + `.../privkey.pem`  
  into `.../fullwithpriv.pem`,  
  a format which can be used in e.g. HAProxy.
