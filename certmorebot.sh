#!/bin/bash
set -e

# default, can be overriden
dns=route53
. config.sh
if [[ "$certmorebot" == "" ]]; then
    echo "\$certmorebot was not defined after loading config.sh"
    echo "Is this the correct data directory?"
    pwd
    exit 1
fi
if [[ "$email" == "" ]]; then
    echo "config.sh must provide email"
    exit 1
fi

dockimage="certbot/dns-${dns}"
ledir="$(pwd)/letsencrypt"
mkdir -p "${ledir}"

haproxyfi() {
    mkdir -p "${ledir}/haproxy"
    pushd "${ledir}/live"
    for domain in *; do
        echo $domain
        cat "${domain}/fullchain.pem" "${domain}/privkey.pem" > "${ledir}/haproxy/${domain}.pem"
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
        --non-interactive \
        --dns-${dns}
    haproxyfi

# run automated renew
elif [[ "$1" == "renew" ]]; then
    docker run --rm --volume "${ledir}:/etc/letsencrypt" \
        ${dockimage} renew \
        --non-interactive
    haproxyfi

else
    echo "What to do?"
    exit 1
fi
