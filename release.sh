#!/bin/bash

set -ex

[[ $1 =~ ^(stable|beta|both)$ ]] || { echo "Invalid channel (stable|beta)." >&2; exit 1; }

channel=$1
docker_image="adamcharnock/avorion"
install_args=""
build_args=""
if [[ $channel == "stable" ]]; then
  tags=("latest")
fi
version=""

build() {
    docker build \
		--build-arg INSTALL_ARGS=" ${install_args}" \
		--build-arg CREATED=$(date -u -Iseconds) \
		--build-arg SOURCE=$(git config --get remote.origin.url) \
		--build-arg REVISION=$(git rev-parse --short HEAD) \
		${build_args} \
		-t "$docker_image:$channel" .

		version=`docker run --rm --entrypoint ./bin/AvorionServer $docker_image:$channel --version`
		tags+=("$version" "$channel")
}
tag() {
    docker tag "$docker_image" "$docker_image:$1"
}
push() {
    docker push "$docker_image:$1"
}

echo "Channel: $channel"

build

for t in ${tags[@]}; do
    tag "$t"
    push "$t"
done
