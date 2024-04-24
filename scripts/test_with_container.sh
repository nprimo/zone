#!/usr/bin/env bash

# Assume all 01 related directories are organized as follows
# tree 01
# .
#├── ...
#├── go-tests
#├── java-tests
#├── runner
#└── ...

set -e

clean_up() {
	rm data.zip
	docker system prune -f 1>/dev/null
}

trap clean_up EXIT

# TODO: make this a values from config, for example .env
Z01_DIR="/home/nprimo/01"
RUNNER_DIR="${Z01_DIR}/runner"

# TODO: make these values as inputs
TEST_LANG="java"
EX_NAME="GoodbyeMars"

# TODO: can be extrapolated from 2 inputs?
EXP_FILE="${EX_NAME}.${TEST_LANG}" # TODO: when is this not true?
SOLUTION_DIR="${Z01_DIR}/${TEST_LANG}-tests/solutions/${EX_NAME}"

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
}

build_test_image() {
	local test_lang_dir="${Z01_DIR}/${1}-tests"
	docker build -t test-image "$test_lang_dir"
}

# TODO: make it works for all lang or make alternatives for each lang
zip_solution_java() {
	STUDENT_DIR="$EX_NAME" # work for Java
	cp -r "$SOLUTION_DIR" "$STUDENT_DIR"
	zip -r data.zip . -i "$STUDENT_DIR"/*
	rm -rf "$STUDENT_DIR"
}

main() {
	if ! docker images | grep runner >/dev/null; then
		echo "Building Runner image"
		build_runner_image
	fi

	if ! docker ps | grep runner >/dev/null; then
		echo "Start runner container"
		start_runner
	fi

	build_test_image ${TEST_LANG}
	if [[ $# -eq 0 ]]; then
		zip_solution_java
	else
		cp "$1" data.zip
	fi

	url="http://localhost:8082/test-image?\
env=FILE=${EXP_FILE}&\
env=EXERCISE=${EX_NAME}"

	echo "Sending to runner..."
	curl -s --data-binary @data.zip "$url" | jq -jr .Output
}

main "$@"
