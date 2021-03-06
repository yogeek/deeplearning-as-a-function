FROM alpine:3.4


# Patch go.c to avoid fd_set error
# https://github.com/pjreddie/darknet/issues/318
# (solution found at : https://github.com/antirez/redis/pull/3303/files)
COPY go.c /tmp/go.c

RUN apk add --update --no-cache \
    build-base curl \
    make \
    gcc \
    git \
    perl \
 && git clone https://github.com/pjreddie/darknet.git \
 && cp /tmp/go.c /darknet/examples/go.c \
 && (cd /darknet && make && rm -rf scripts src results obj .git) \
 && curl -O http://pjreddie.com/media/files/extraction.weights \
 && curl -O https://pjreddie.com/media/files/yolo.weights \
 && apk del \
    build-base \
    ca-certificates \
    curl \
    gcc \
    git \
    libcurl \
    libgcc \
    libssh2 \
    pcre \
    perl \
    make \
    musl-dev \
 && rm -rf /var/cache/apk/*

# Get Minio client
ADD https://dl.minio.io/client/mc/release/linux-amd64/mc /usr/bin
RUN chmod +x /usr/bin/mc

# Get fwatchdog
#
ADD https://github.com/openfaas/faas/releases/download/0.6.10/fwatchdog /usr/bin
RUN chmod +x /usr/bin/fwatchdog

COPY darknet.sh /
RUN chmod +x /darknet.sh

ENV fprocess="/darknet.sh"

WORKDIR "/darknet"

HEALTHCHECK --interval=5s CMD [ -e /tmp/.lock ] || exit 1
CMD ["fwatchdog"]
