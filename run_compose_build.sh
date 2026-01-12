#!/usr/bin/env bash

export CREATED=$(date +%Y-%m-%dT%H:%M:%SZ)
export DIGEST=$(docker buildx imagetools inspect alpine:latest --format "{{json .Manifest.Digest}}" | sed -e 's/"//g' | cut -d":" -f2)
export REVISION=$(git rev-parse HEAD | cut -c1-8)
export VERSION=$(curl -sX GET "https://api.github.com/repos/syncthing/syncthing/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]')

docker compose -f compose.build.yaml up -d --build

unset CREATED
unset DIGEST
unset REVISION
unset VERSION
