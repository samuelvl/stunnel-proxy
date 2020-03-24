# TLS configuration
sslVersion = TLSv1.2
options    = NO_TLSv1.1
options    = NO_SSLv3
cert       = ${SERVICE_CERTIFICATE}

# Process configuration
foreground = yes
socket     = l:TCP_NODELAY=1
socket     = r:TCP_NODELAY=1

# Tunnel configuration
[${SERVICE_NAME}]
accept       = ${LISTENING_PORT}
connect      = ${SERVICE_HOST}:${SERVICE_PORT}
TIMEOUTclose = 0
