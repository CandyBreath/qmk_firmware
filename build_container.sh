#!/usr/bin/env bash


BUILD_FLAGS=""
CLEAN_ARGS=()

# Loop through all arguments
for arg in "$@"; do
  if [[ "$arg" == "--debug" ]]; then
    BUILD_FLAGS+=" --progress=plain --no-cache"
  else
    CLEAN_ARGS+=("$arg")
  fi
done

docker build $BUILD_FLAGS $CLEAN_ARGS --build-arg USER_UID=$(id -u) --build-arg USER_GID=$(id -g) -t qmk_environment .