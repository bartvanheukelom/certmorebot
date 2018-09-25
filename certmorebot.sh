#!/bin/bash
set -e
cd "$(dirname "$0")"

# default, can be overriden
dns=route53
. config.sh
if [[ "$email" == "" ]]; then
    echo "config.sh must provide email"
    exit 1
fi

dockimage="certbot/dns-${dns}"
ledir="$(pwd)/letsencrypt"
mkdir -p "${ledir}"

haproxyfi() {
    pushd "${ledir}/live"
    for domain in *; do
        echo $domain
        cat "${domain}/fullchain.pem" "${domain}/privkey.pem" > "${domain}/fullwithpriv.pem"
    done
    popd
}

# run any certbot command interactively
if [[ "$1" == "cmd" ]]; then
    
    docker run --rm --volume "${ledir}:/etc/letsencrypt" \
        -it \
        ${dockimage} "${@:2}"

# add a domain to manage
elif [[ "$1" == "add" ]]; then
    
    docker run --rm --volume "${ledir}:/etc/letsencrypt" \
        -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY \
        ${dockimage} certonly --domain "$2" --email "${email}" --agree-tos \
        --dns-${dns}
    haproxyfi

# run automated renew
elif [[ "$1" == "renew" ]]; then
    docker run --rm --volume "${ledir}:/etc/letsencrypt" \
        ${dockimage} renew
    haproxyfi

else
    echo "What to do?"
    exit 1
fi
