# Stunnel container

Run a container to create a TLS encryption tunnel using `stunnel` for those services and applications that do not support TLS (e.g. HTTP, LDAP, SMTP, Redis, etc).

## Configuration

Using the following environment variables.

|        Name         |                Description                |                Default                |   Example    |
| :-----------------: | :---------------------------------------: | :-----------------------------------: | :----------: |
|   LISTENING_PORT    |    TPC port where stunnel is listening    |                   -                   |     8081     |
|    SERVICE_NAME     |       Name of the external service        |                   -                   |     http     |
|    SERVICE_HOST     |  Hostname or IP of the external service   |               localhost               | portquiz.net |
|    SERVICE_PORT     |      TCP por to forward the traffic       |                   -                   |     8080     |
| SERVICE_CERTIFICATE | Certificate for the service in PEM format | /etc/stunnel/certificates/service.pem |      -       |

## TLS certificate

The certificate and private key can be loaded from different sources.

- PEM certificate.
- CRT + Key certificate.
- Self-signed certicate.

### PEM certificate

The certificate is loaded from `/etc/stunnel/certificates/service.pem` file, it includes the certificate and private key in Base64 format.

### CRT + Key certificate

The public and private certificate parts are separated in `/etc/stunnel/certificates/service.crt` and `/etc/stunnel/certificates/service.key` files. The `entrypoint.sh` script will merge these two files in a single one with PEM format.

### Self-signed certificate

If no certificate is set, the `entrypoint.sh` script will create a self-signed certificate using the `SERVICE_HOST` as CN.

## Example

Create an HTTP tunnel against `portquiz.net`, it is an HTTP server with no TLS encryption that exposes all possible ports for testing purposes.

```bash
podman run --name="stunnel" -d --rm \
    -e="LISTENING_PORT=8081" \
    -e="SERVICE_NAME=http" \
    -e="SERVICE_HOST=portquiz.net" \
    -e="SERVICE_PORT=8080" \
    -p="8081:8081" \
    samuvl/stunnel-container:1.0.0
```

Check if the tunnel is exposing the TLS certificate correctly.

```
openssl s_client -showcerts -connect localhost:8081 </dev/null
```

Check also if the traffic is being forwarded.

```
curl -k https://localhost:8081
```

## References

- https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/security_guide/sec-using_stunnel