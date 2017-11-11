FROM think/darknet
# Use a darknet as a base image
# TODO : update the image because it does not build anymore...
# (problem with gcc alpine package version ?)

# Get fwatchdog
#
ADD https://github.com/openfaas/faas/releases/download/0.6.7/fwatchdog /usr/bin
RUN chmod +x /usr/bin/fwatchdog

WORKDIR /root

COPY darknet.sh .

# Populate example here - i.e. "cat", "sha512sum" or "node index.js"
ENV fprocess="./darknet.sh"

# Remove base image entrypoint (to not interfere with fwatchdog)
ENTRYPOINT [""]

HEALTHCHECK --interval=5s CMD [ -e /tmp/.lock ] || exit 1
CMD ["fwatchdog"]
