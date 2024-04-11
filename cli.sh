#!/usr/bin/env bash

RUNNER_DIR="/home/nprimo/01/runner"

start_runner() {
	docker container rm --force runner 2>/dev/null
	docker run \
		--detach \
		--name runner \
		--log-opt max-size=100m \
		--log-opt max-file=2 \
		--env REGISTRY_PASSWORD \
		--restart unless-stopped \
		--publish 8082:8080 \
		--volume /var/run/docker.sock:/var/run/docker.sock:ro \
		runner
}

build_runner_image() {
	docker build -t runner ${RUNNER_DIR}
	docker system prune -f
}

if ! docker images | grep runner >/dev/null; then
	echo "Building Runner image"
	build_runner_image
fi

if ! docker ps | grep runner >/dev/null; then
	echo "Start runner container"
	start_runner
fi

# build test image based on test path
# zip solution - IMPORTANT: include only required files with the "expected" path
# run curl command
