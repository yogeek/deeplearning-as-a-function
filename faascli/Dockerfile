FROM alpine

RUN apk add --no-cache curl su-exec docker && \
    curl -sSL https://cli.openfaas.com | sh

# Add entrypoint to dynamically change user uid when a container is started
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

