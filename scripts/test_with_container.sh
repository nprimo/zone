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
	local test_lang_dir="${Z01_DIR}/$1-tests"
	docker build -t test-image "$test_lang_dir"
}

# TODO: make it works for all lang or make alternatives for each lang
zip_solution_java() {
	local ex_name=$1
	local solution_dir=$2
	STUDENT_DIR="$ex_name" 

	cp -r "$solution_dir" "$STUDENT_DIR"
	zip -r data.zip . -i "$STUDENT_DIR"/*
	rm -rf "$STUDENT_DIR"
}

main() {
	#EX_NAME="GoodbyeMars"
	#TEST_LANG="java"
	local ex_name=$1
	local test_lang=$2
	local solution_dir="${Z01_DIR}/${test_lang}-tests/solutions/${ex_name}"

	EXP_FILE="${ex_name}.${test_lang}" # TODO: when is this not true?

	if ! docker images | grep runner >/dev/null; then
		echo "Building Runner image"
		build_runner_image
	fi

	if ! docker ps | grep runner >/dev/null; then
		echo "Start runner container"
		start_runner
	fi

	build_test_image "$test_lang"
	# TODO: make a way to send solution or zip the other lang solutions
	zip_solution_java "$ex_name" "$solution_dir"

	url="http://localhost:8082/test-image?\
env=FILE=${EXP_FILE}&\
env=EXERCISE=${ex_name}"

	echo "Sending to runner..."
	curl -s --data-binary @data.zip "$url" | jq -jr .Output
}

main "$@"
