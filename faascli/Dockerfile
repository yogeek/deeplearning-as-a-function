FROM alpine

RUN apk add --update curl && \
    apk add --no-cache su-exec && \
    curl -sSL https://cli.openfaas.com | sh && \
    rm -rf /var/cache/apk/*

# Add entrypoint to dynamically change user uid when a container is started
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

