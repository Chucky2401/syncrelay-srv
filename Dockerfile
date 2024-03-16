FROM alpine:3.19

LABEL fr.blackwizard.author="Chucky2401" \
    fr.blackwizard.description="Syncthing RelaySrv" \
    fr.blackwizard.version="0.1.2" \
    fr.blackwizard.source="https://github.com/Chucky2401/syncrelay-srv" \
    fr.blackwizard.support="https://github.com/Chucky2401/syncrelay-srv/issues" \
    fr.blackwizard.url="https://blackwizard.fr" \
    fr.blackwizard.vendor="The Syncthing Project" \
    fr.blackwizard.vendor.url="https://syncthing.net" \
    fr.blackwizard.vendor.documentation="https://docs.syncthing.net"

RUN \
    echo "*** Update APK ***" ; \
    apk update ; apk upgrade ; \
    echo "*** Install Utils ***" ; \
    apk add --no-cache ca-certificates bash xz bind-tools shadow ; \
    echo "*** Install syncthing-utils ***" ; \
    apk add --no-cache syncthing-utils

ARG S6_OVERLAY_VERSION="3.1.6.2"
ARG S6_OVERLAY_ARCH="aarch64"

# add s6 overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCH}.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-${S6_OVERLAY_ARCH}.tar.xz

# add s6 optional symlinks
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-arch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-symlinks-arch.tar.xz

RUN \
  echo "*** Create 'syncrelay' user and create folder ***" ; \
  groupmod -g 1000 users ; \
  useradd -u 911 -U -d /var/strelaysrv -s /bin/bash syncrelay ; \
  usermod -G users syncrelay ; \
  mkdir -p /var/strelaysrv ; \
  echo "*** Cleanup ***" ; \
  rm -rf /tmp/*

RUN \
  rm -f /etc/profile.d/color_prompt.sh.disabled

COPY src/ /

ENV PRIVATE="" TOKEN="" EXTERNAL_ADDRESS="" PORT="22067" POOLS="https://relays.syncthing.net/endpoint"
ENV ENV="/etc/profile"
ENV VERSION="0.1.2"
ENV PUID=1000 PGID=1000 

EXPOSE 22067 22070

VOLUME ["/var/strelaysrv"]

HEALTHCHECK --interval=1m --timeout=10s \
  CMD nc -z localhost 22067 || exit 1

ENTRYPOINT ["/init"]
