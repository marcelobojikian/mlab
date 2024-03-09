#!/usr/bin/env bats

setup() {
    load "$PROJECT_ROOT/test/test_helper/bats_setup"
    _path_setup global
    TEST_DIR=$(mktemp -du)
}

teardown() {
    rm -rf "$TEST_DIR"
    echo "status: ${status}"
    echo "output: ${output}"
}

@test "No command or option" {
    run cache.sh enable --url="http://teste.url" --path=$TEST_DIR
    run cache.sh
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "No command or option." ]]
    [[ "${lines[1]}" == "Try 'mlab cache -h' for more information." ]]
}

@test "Invalid command" {
    run cache.sh enable --url="http://teste.url" --path=$TEST_DIR
    run cache.sh XYZ
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Invalid command: XYZ" ]]
    [[ "${lines[1]}" == "Try 'mlab cache -h' for more information." ]]
}

@test "No command with path option " {
    run cache.sh --path="$TEST_DIR"

    [[ ! -d "$TEST_DIR" ]]

    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "No command or option." ]]
    [[ "${lines[1]}" == "Try 'mlab cache -h' for more information." ]]
}
