#!/usr/bin/env bash

TOKEN_FILE=${1}
DOMAINS=${2}

GOOGLE_IP=$(curl -s http://whatismyip.akamai.com/)

function get_domain_id() {
    DOMAIN=${1}

    ID=$(curl -s https://api.digitalocean.com/v2/domains/${DOMAIN}/records?type=A \
              -K ${TOKEN_FILE} \
            | jq -r .domain_records[].id)
    echo ${ID}
}

function update_domain_ip() {
    DOMAIN_NAME=${1}
    DOMAIN_ID=${2}

    curl -s -X PUT https://api.digitalocean.com/v2/domains/${DOMAIN_NAME}/records/${DOMAIN_ID} \
         -K ${TOKEN_FILE} \
         -H "Content-type: application/json" \
         -H "Cache-control: no-cache" \
         -d "{\"data\": \"${GOOGLE_IP}\"}"
    echo
}

for D in ${DOMAINS}; do
    DOMAIN_IP=$(dig +short ${D})
    if [ "${DOMAIN_IP}" != "${GOOGLE_IP}" ]; then
        DID=$(get_domain_id $D)
        echo "Updating ${D} IP to ${GOOGLE_IP}"
        RESPONSE=$(update_domain_ip ${D} ${DID})
        echo ${RESPONSE}
    fi
done

