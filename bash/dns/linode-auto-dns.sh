#!/usr/bin/env bash

API="https://api.linode.com/v4/"
TOKEN_FILE=${1}
DOMAINS=${2}

HOME_IP=$(curl -s http://whatismyip.akamai.com/)

function get_domain_id() {
    DOMAIN=${1}

    ID=$(curl -s --location "${API}domains" -K ${TOKEN_FILE} \
        | jq --arg DOMAIN ${DOMAIN} '.data[] | select(.domain==$DOMAIN) | .id')
    echo ${ID}

}

function get_domain_record_id() {
    DOMAIN_ID=${1}

    RECORD_ID=$(curl -s --location "${API}domains/${DOMAIN_ID}/records" -K ${TOKEN_FILE} \
        | jq -r '.data[] | select(.type=="A" and .name=="") | .id')
    
    echo $RECORD_ID
}

function update_domain_ip() {
    DOMAIN_ID=${1}
    RECORD_ID=${2}
    DOMAIN=${3}

    curl -s -X PUT "${API}domains/${DOMAIN_ID}/records/${RECORD_ID}" \
         -K ${TOKEN_FILE} \
         -H "Content-type: application/json" \
         -H "Cache-control: no-cache" \
         -d "{\"name\": \"${DOMAIN}\", \"target\": \"${HOME_IP}\"}"
    echo
}

for D in ${DOMAINS}; do
    DOMAIN_IP=$(dig +short ${D})
    if [ "${DOMAIN_IP}" != "${HOME_IP}" ]; then
        DID=$(get_domain_id $D)
        RID=$(get_domain_record_id $DID)
        echo "Updating ${D} IP to ${HOME_IP}"
        RESPONSE=$(update_domain_ip ${DID} ${RID} ${D})
        echo ${RESPONSE}
    fi
done
