FROM alpine:latest AS builder

ARG VERSION

RUN \
  if [[ -z "${VERSION}" ]]; then \
    exit 1 ;\
  fi && \
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
  mkdir -p /tmp/sync && \
  curl -o /tmp/syncthing-src.tar.gz -L "https://github.com/syncthing/syncthing/releases/download/${VERSION}/syncthing-source-${VERSION}.tar.gz" && \
  tar xf /tmp/syncthing-src.tar.gz -C /tmp/sync --strip-components=1 && \
  echo "**** Compile syncthing  ****" && \
  cd /tmp/sync && \
  go clean -modcache && \
  CGO_ENABLED=0 go run build.go --no-upgrade build strelaysrv

#
# Final Stage
#
FROM alpine:latest

LABEL fr.blackwizard.author="Chucky2401" \
    fr.blackwizard.description="Syncthing Relay Server" \
    fr.blackwizard.source="https://github.com/Chucky2401/syncrelay-srv" \
    fr.blackwizard.support="https://github.com/Chucky2401/syncrelay-srv/issues" \
    fr.blackwizard.url="https://blackwizard.fr" \
    fr.blackwizard.vendor="The Syncthing Project" \
    fr.blackwizard.vendor.url="https://syncthing.net" \
    fr.blackwizard.vendor.documentation="https://docs.syncthing.net"
ARG VERSION

COPY --from=builder /tmp/sync/strelaysrv /usr/bin/
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
  if [[ -z "${VERSION}" ]]; then \
    exit 1 ;\
  fi && \

ENV PRIVATE="" TOKEN="" EXTERNAL_ADDRESS="" PORT="22067" POOLS="https://relays.syncthing.net/endpoint"
ENV PUID=1000 PGID=1000 

EXPOSE 22067 22070

VOLUME ["/var/strelaysrv"]

HEALTHCHECK --interval=1m --timeout=10s \
  CMD nc -z localhost 22067 || exit 1

