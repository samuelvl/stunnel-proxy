#!/usr/bin/env bash

set -o errexit  # exit when a command fails
set -o nounset  # exit when use undeclared variables
set -o pipefail # return the exit code of the last command that threw a non-zero

# Merge CRT and key into PEM file
function merge_certificate {
    local serviceCertificateCRT=${1}
    local serviceCertificateKey=${2}
    local serviceCertificate=${3}

    cat ${serviceCertificateCRT} > ${serviceCertificate}
    cat ${serviceCertificateKey} >> ${serviceCertificate}
}

# Generate a self-signed certificate
function generate_certificate {
    local serviceHost=${1}
    local serviceCertificate=${2}
    local serviceCertificateKey="${serviceCertificate}.key"

    openssl req -new -x509 -nodes -sha1 -days 31 \
        -subj "/C=ES/ST=Madrid/L=Madrid/O=Red Hat/CN=${serviceHost}" \
        -keyout ${serviceCertificateKey} -out ${serviceCertificate}

    cat ${serviceCertificateKey} >> ${serviceCertificate}
    rm -f ${serviceCertificateKey}
}

# Get input variables
export LISTENING_PORT=${LISTENING_PORT}
export SERVICE_NAME=${SERVICE_NAME}
export SERVICE_HOST=${SERVICE_HOST:-localhost}
export SERVICE_PORT=${SERVICE_PORT}
export SERVICE_CERTIFICATE=${SERVICE_CERTIFICATE:-/etc/stunnel/certificates/service.pem}

# Generate PEM certificate
if [ ! -f ${SERVICE_CERTIFICATE} ]; then
    SERVICE_CERTIFICATE_CRT="${STUNNEL_CERTS_DIR}/service.crt"
    SERVICE_CERTIFICATE_KEY="${STUNNEL_CERTS_DIR}/service.key"

    # Merge CRT and key into PEM file
    if [ -f ${SERVICE_CERTIFICATE_CRT} ] && [ -f ${SERVICE_CERTIFICATE_KEY} ]; then
        merge_certificate ${SERVICE_CERTIFICATE_CRT} ${SERVICE_CERTIFICATE_KEY} ${SERVICE_CERTIFICATE}
    # Generate a self-signed certificate
    else
        generate_certificate ${SERVICE_HOST} ${SERVICE_CERTIFICATE}
    fi
fi

# Render stunnel configuration
envsubst < ${STUNNEL_CONF_DIR}/stunnel.conf.tpl > ${STUNNEL_CONF_DIR}/stunnel.conf

# Start stunnel
stunnel ${STUNNEL_CONF_DIR}/stunnel.conf