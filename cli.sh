#!/usr/bin/env bash

set -e

# TODO: make this more flexible - coming from arguments?
# use a 01_DIR path and "assume" all the other (tests ...) are inside.
# TEST_LAND_DIR, could become TEST_LANG

Z01_DIR="/home/nprimo/01"

RUNNER_DIR="${Z01_DIR}/runner"
#TEST_LANG_DIR="/home/nprimo/01/java-tests"
TEST_LANG_DIR="${Z01_DIR}/go-tests"

EX_NAME="displaya"
EXP_FILE="displaya/main.go"
#SOLUTION_DIR="$Z01_DIR}/java-tests/solutions/GoodbyeMars"
SOLUTION_DIR="${Z01_DIR}/piscine-go/displaya"

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
	#STUDENT_DIR="$EX_NAME" # work for Java
	STUDENT_DIR="student"
	# TODO: check if it works for all lang
	cp -r "$SOLUTION_DIR" "$STUDENT_DIR"
	#zip -r data.zip . -i "$STUDENT_DIR"/*
	zip -r data.zip . -i "$STUDENT_DIR"/* -j "$STUDENT_DIR"
	rm -rf "$STUDENT_DIR"
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

url="http://localhost:8082/test-image?\
env=FILE=${EXP_FILE}&\
env=EXERCISE=${EX_NAME}"

curl --data-binary @data.zip "$url" | jq -jr .Output


# TODO: make a "clean_up" function?
rm data.zip
