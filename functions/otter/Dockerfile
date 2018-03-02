FROM alpine

ADD https://github.com/openfaas/faas/releases/download/0.6.10/fwatchdog /usr/bin
RUN chmod +x /usr/bin/fwatchdog

WORKDIR /root

COPY otter.sh .

# Populate example here - i.e. "cat", "sha512sum" or "node index.js"
ENV fprocess="/root/otter.sh"

# Remove base image entrypoint (to not interfere with fwatchdog)
ENTRYPOINT []

HEALTHCHECK --interval=5s CMD [ -e /tmp/.lock ] || exit 1
CMD ["/usr/bin/fwatchdog"]
