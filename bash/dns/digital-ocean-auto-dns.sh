#!/usr/bin/env bash

DOMAIN=${1}
RECORD_ID=${2}

BEARER_TOKEN="XXX-YOUR-TOKEN-HERE-XXX"
MYIP=$(curl -s http://whatismyip.akamai.com/)
XYZIP=$(dig +short ${DOMAIN})

echo ${MYIP}
echo ${XYZIP}

if [ "${MYIP}" != "${XYZIP}" ]; then
    echo "IP's don't match. Updating."

    curl -X PUT https://api.digitalocean.com/v2/domains/${DOMAIN}/records/${RECORD_ID} \
        -H "Authorization: Bearer ${BEARER_TOKEN}" \
        -H 'Content-type: application/json' \
        -H 'cache-control: no-cache' \
        -d "{\"data\": \"${MYIP}\"}"
    echo
fi

