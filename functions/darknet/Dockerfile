# Docker Image for Darknet ImageNet implementation on OpenFaaS
# 
# Darknet network takes an image in input and provides predictions for all categories found in the image.
#
# Example :
# cat your_image.jpg | docker run -i think/darknet
# bald eagle: 0.809800
# kite: 0.179002
# vulture: 0.004752
# prairie chicken: 0.000786
# hen: 0.000612


FROM think/darknet
# Use a darknet as a base image
# TODO : update the image because it does not build anymore...
# (problem with gcc alpine package version ?)

# Remove base image entrypoint (to not interfere with fwatchdog)
ENTRYPOINT []

# Get fwatchdog
#
ADD https://github.com/openfaas/faas/releases/download/0.6.10/fwatchdog /usr/bin
RUN chmod +x /usr/bin/fwatchdog

COPY darknet.sh /

ENV fprocess="/darknet.sh"

HEALTHCHECK --interval=5s CMD [ -e /tmp/.lock ] || exit 1
CMD ["fwatchdog"]
