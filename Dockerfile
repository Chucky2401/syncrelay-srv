FROM alpine:3.21.2 AS builder

ARG S6_OVERLAY_VERSION="3.2.0.2"

RUN \
  echo "**** Install build packages ****" && \
  apk add --no-cache \
    build-base \
    go \
    curl \
    tar \
    bash \
    ca-certificates \
    xz \
    coreutils && \
  echo "**** Fetch Synchting source code ****" && \
  if [ -z ${SYNCTHING_RELEASE+x} ]; then \
  SYNCTHING_RELEASE=$(curl -sX GET "https://api.github.com/repos/syncthing/syncthing/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  mkdir -p /tmp/sync && \
  curl -o /tmp/syncthing-src.tar.gz -L "https://github.com/syncthing/syncthing/releases/download/${SYNCTHING_RELEASE}/syncthing-source-${SYNCTHING_RELEASE}.tar.gz" && \
  tar xf /tmp/syncthing-src.tar.gz -C /tmp/sync --strip-components=1 && \
  echo "**** Compile syncthing  ****" && \
  cd /tmp/sync && \
  go clean -modcache && \
  CGO_ENABLED=0 go run build.go --no-upgrade build strelaysrv && \
  echo "**** Fetch s6-overlay ****" && \
  mkdir /tmp/s6-out && \
  cd /tmp && \
  S6_OVERLAY_ARCH=$(uname -m) && \
  curl -o s6-overlay-noarch.tar.xz -L https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz && \
  curl -o s6-overlay-${S6_OVERLAY_ARCH}.tar.xz -L https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCH}.tar.xz && \
  curl -o s6-overlay-symlinks-noarch.tar.xz -L https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz && \
  curl -o s6-overlay-symlinks-arch.tar.xz -L https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-arch.tar.xz && \
  echo "**** Extract s6-overlay ****" && \
  tar -C /tmp/s6-out -Jxpf /tmp/s6-overlay-noarch.tar.xz && \
  tar -C /tmp/s6-out -Jxpf /tmp/s6-overlay-${S6_OVERLAY_ARCH}.tar.xz && \
  tar -C /tmp/s6-out -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz && \
  tar -C /tmp/s6-out -Jxpf /tmp/s6-overlay-symlinks-arch.tar.xz

#
# Final Stage
#
FROM alpine:3.21.2

LABEL fr.blackwizard.author="Chucky2401" \
    fr.blackwizard.version="1.27.7-r3" \
    fr.blackwizard.description="Syncthing Relay Server" \
    fr.blackwizard.source="https://github.com/Chucky2401/syncrelay-srv" \
    fr.blackwizard.support="https://github.com/Chucky2401/syncrelay-srv/issues" \
    fr.blackwizard.url="https://blackwizard.fr" \
    fr.blackwizard.vendor="The Syncthing Project" \
    fr.blackwizard.vendor.url="https://syncthing.net" \
    fr.blackwizard.vendor.documentation="https://docs.syncthing.net"

COPY --from=builder /tmp/sync/strelaysrv /usr/bin/
COPY --from=builder /tmp/s6-out/ /
COPY src/ /

RUN \
  echo "*** Install Utils ***" ; \
  apk add --no-cache ca-certificates bash xz bind-tools shadow ; \
  echo "*** Create 'syncrelay' user and create folder ***" ; \
  groupmod -g 1000 users ; \
  useradd -u 911 -U -d /var/strelaysrv -s /bin/bash syncrelay ; \
  usermod -G users syncrelay ; \
  mkdir -p /var/strelaysrv ; \
  echo "*** Cleanup ***" ; \
  apk cache clean ; \
  rm -rf /tmp/* ; \
  rm -f /etc/profile.d/color_prompt.sh.disabled

ENV PRIVATE="" TOKEN="" EXTERNAL_ADDRESS="" PORT="22067" POOLS="https://relays.syncthing.net/endpoint"
ENV ENV="/etc/profile"
ENV PUID=1000 PGID=1000 

EXPOSE 22067 22070

VOLUME ["/var/strelaysrv"]

HEALTHCHECK --interval=1m --timeout=10s \
  CMD nc -z localhost 22067 || exit 1

ENTRYPOINT ["/init"]
