#!/usr/bin/env bats

setup() {
    load "$PROJECT_ROOT/test/test_helper/bats_setup"
    _path_setup global

    CACHE_DIR_CONF=~/.mlab/cache 
    CACHE_FILE_CONF=$CACHE_DIR_CONF/conf.txt

    TEST_DIR=$(mktemp -du)
    echo "TEST_DIR: ${TEST_DIR}"
}

teardown() {
    rm -rf "$TEST_DIR"
    echo "status: ${status}"
    echo "output: ${output}"
}

get_config() {
    echo $(cat "$CACHE_FILE_CONF" | grep "$1" | cut -d'=' -f2)
}

@test "Invalid command when option is before command" {
    run cache.sh --path=$TEST_DIR delete     
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "No command or option." ]]
    [[ "${lines[1]}" == "Try 'mlab cache -h' for more information." ]]
}

@test "Delete cache" {
    run cache.sh enable --url="http://teste.url"
    [[ "${status}" -eq 0 ]]
    [[ -d "$CACHE_DIR_CONF" ]]
    
    path_value=$(get_config PATH)
    [[ "$path_value" == "$CACHE_DIR_CONF" ]]

    run cache.sh delete
    [[ "${status}" -eq 0 ]]
    [[ ! -d "$CACHE_DIR_CONF" ]]
}

@test "Delete cache with path" {
    run cache.sh enable --url="http://teste.url" --path=$TEST_DIR
    [[ "${status}" -eq 0 ]]
    
    path_value=$(get_config PATH)
    [[ "$path_value" == "$TEST_DIR" ]]

    run cache.sh delete
    [[ "${status}" -eq 0 ]]
    [[ ! -d "$TEST_DIR" ]]
    [[ ! -d "$CACHE_DIR_CONF" ]]
}
