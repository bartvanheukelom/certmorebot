# certmorebot

Simple wrapper script for LetsEncrypt `certbot`,
managing a local certificate store,
for domains using AWS Route 53 or other DNS services.

- Requires Docker (but data is stored outside of it)
- Run as root

## Usage

- Copy `sample-config.sh` to `config.sh` and edit.
- Add cert for a domain: `certmorebot.sh add '*.cooldomain.org'`
- Automatic renewals: set a daily cron job for `certmorebot.sh renew`
- After adding or renewing, certmorebot will also concat  
  `live/*/fullchain.pem` + `.../privkey.pem`  
  into `.../fullwithpriv.pem`,  
  which can be used in e.g. HAProxy
