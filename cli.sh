#!/usr/bin/env bash

set -e 

# TODO: make this more flexible - coming from arguments?
RUNNER_DIR="/home/nprimo/01/runner"
TEST_LANG_DIR="/home/nprimo/01/java-tests"
EX_NAME="GoodbyeMars"
EXP_FILE="GoodbyeMars.java"
SOLUTION_DIR="/home/nprimo/01/java-tests/solutions/GoodbyeMars"

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

build_test_image() {
	docker build -t test-image ${TEST_LANG_DIR}
	docker image prune -f
}

zip_solution() {
	# TODO: check if it works for all lang
	cp -r "$SOLUTION_DIR" "$EX_NAME"
	zip -r data.zip . -i "$EX_NAME"/*
    rm -rf "$EX_NAME"
}

if ! docker images | grep runner >/dev/null; then
	echo "Building Runner image"
	build_runner_image
fi

if ! docker ps | grep runner >/dev/null; then
	echo "Start runner container"
	start_runner
fi

build_test_image
zip_solution

curl --data-binary @data.zip "http://localhost:8082/test-image?env=FILE=${EXP_FILE}a&env=EXERCISE=${EX_NAME}" |
    jq -jr .Output

# TODO: make a "clean_up" function?
rm data.zip
