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
alldir="$(pwd)/all"
mkdir -p "${ledir}"

haproxyfi() {
    mkdir -p "${alldir}"

    if [[ -d "${ledir}/live" ]]; then
        pushd "${ledir}/live"
        for domain in *; do
            echo $domain
            cat "${domain}/fullchain.pem" "${domain}/privkey.pem" > "${alldir}/${domain}.pem"
        done
        popd
    fi

    if [[ -d "manual" ]]; then
        pushd "manual"
        for domain in *; do
            echo $domain
            cat "${domain}/fullchain.pem" "${domain}/privkey.pem" > "${alldir}/${domain}.pem"
        done
        popd
    fi

    # Copy to old location (deprecated)
    pushd "${alldir}"
    for f in *; do
        mkdir -p "${ledir}/haproxy"
	cp "${f}" "${ledir}/haproxy/${f}"
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
