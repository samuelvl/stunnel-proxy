FROM docker.io/centos:centos8.1.1911

# Configuration variables
ENV STUNNEL_RPM_PACKAGE="stunnel-5.48-5.el8.0.1" \
    STUNNEL_CONF_DIR="/etc/stunnel/configuration" \
    STUNNEL_CERTS_DIR="/etc/stunnel/certificates"

# Install stunnel
RUN dnf install -y ${STUNNEL_RPM_PACKAGE} gettext openssl &&\
    rm -r /var/cache/dnf

# Create stunnel user
RUN useradd --uid 1001 --system --create-home \
    --gid 0 --groups tty --shell /sbin/nologin stunnel

# Update stunnel configuration
COPY --chown=stunnel:root \
    configuration ${STUNNEL_CONF_DIR}

# Create certificates folder
RUN install -d -o stunnel -g root ${STUNNEL_CERTS_DIR}

# Allow root group to write in stunnel directories
RUN chmod 775 ${STUNNEL_CONF_DIR} ${STUNNEL_CERTS_DIR}

# Copy entrypoint
COPY entrypoint.sh .

# Switch to stunnel user
USER stunnel

# Run stunnel at startup
CMD ["./entrypoint.sh"]
