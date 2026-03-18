#!/usr/bin/env bash

set -eou pipefail

if [ "${GITHUB_EVENT_NAME}" = "pull_request" ]; then
  RAW_TAG=${GITHUB_HEAD_REF}
else
  RAW_TAG=${GITHUB_REF_NAME}
fi
TAG=$(echo "$RAW_TAG" | sed 's/[^a-zA-Z0-9._-]//g' | awk '{print substr($0, length($0)-120)}')

echo "Final TAG is: $TAG"

PLATFORM="amd64"
if [ "$RUNNER_ARCH" = "ARM64" ]; then
  PLATFORM="arm64"
fi

if [ "${DOCKER_IMAGE}" = "ghcr.io/lehigh-university-libraries/" ]; then
  DOCKER_IMAGE="ghcr.io/${GITHUB_REPOSITORY,,}"
fi

CACHE_TO=""
if [ "${TAG}" = "main" ]; then
  CACHE_TO="type=registry,ref=$DOCKER_IMAGE:cache-$PLATFORM,mode=max"
fi

CACHE_FROM="type=registry,ref=$DOCKER_IMAGE:cache-$PLATFORM"

{
  echo "image=$DOCKER_IMAGE"
  echo "platform=$PLATFORM"
  echo "tag=$TAG"
  echo "cache-to=$CACHE_TO"
  echo "cache-from=$CACHE_FROM"
} >> "$GITHUB_OUTPUT"
