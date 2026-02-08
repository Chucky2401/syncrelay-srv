FROM alpine:latest AS builder

ARG VERSION

RUN mkdir -p /tmp/sync

WORKDIR /tmp/sync

RUN \
  if [ -z "${VERSION}" ]; then \
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
  curl -o /tmp/syncthing-src.tar.gz -L "https://github.com/syncthing/syncthing/releases/download/${VERSION}/syncthing-source-${VERSION}.tar.gz" && \
  tar xf /tmp/syncthing-src.tar.gz -C /tmp/sync --strip-components=1 && \
  echo "**** Compile syncthing  ****" && \
  go clean -modcache && \
  CGO_ENABLED=0 go run build.go --no-upgrade build strelaysrv

#
# Final Stage
#
FROM alpine:latest

ARG CREATED
ARG DIGEST
ARG REVISION
ARG VERSION

LABEL org.opencontainers.image.authors="Chucky2401"
LABEL org.opencontainers.image.base.digest=$DIGEST
LABEL org.opencontainers.image.base.name="alpine:latest"
LABEL org.opencontainers.image.created=$CREATED
LABEL org.opencontainers.image.description="Syncthing Relay Server"
LABEL org.opencontainers.image.documentation="https://docs.syncthing.net"
LABEL org.opencontainers.image.url="https://syncthing.net"
LABEL org.opencontainers.image.revision=$REVISION
LABEL org.opencontainers.image.source="https://syncthing.net"
LABEL org.opencontainers.image.version=$VERSION

COPY --from=builder --chmod=555 /tmp/sync/strelaysrv /usr/bin/
COPY --chmod=555 src/ /

ENV PUID=1000 PGID=1000

RUN \
  if [ -z "${VERSION}" ]; then \
    exit 1 ;\
  fi && \
  echo "*** Update packages ***" && \
  apk update --no-cache && \
  echo "*** Install Utils ***" && \
  apk add --no-cache ca-certificates shadow && \
  echo "*** Create 'syncrelay' user and create folder ***" && \
  addgroup -g ${PGID} syncrelay && \
  adduser -D -u ${PUID} -h /var/strelaysrv -G syncrelay syncrelay && \
  echo "*** Change permission on /entrypoint.sh" && \
  chmod +x /entrypoint.sh && \
  echo "*** Cleanup ***" && \
  apk cache clean && \
  rm -rf /tmp/*

ENV PRIVATE="" TOKEN="" EXTERNAL_ADDRESS="" PORT="22067" POOLS="https://relays.syncthing.net/endpoint"

EXPOSE 22067 22070

VOLUME ["/var/strelaysrv"]
WORKDIR /var/strelaysrv

HEALTHCHECK --interval=1m --timeout=10s \
  CMD nc -z localhost 22067 || exit 1

ENTRYPOINT ["/entrypoint.sh"]
