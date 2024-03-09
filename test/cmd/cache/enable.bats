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
    echo PATH: $(get_config PATH)
    echo URL: $(get_config URL)
    echo "status: ${status}"
    echo "output: ${output}"
}

get_config() {
    echo $(cat "$CACHE_FILE_CONF" | grep "$1" | cut -d'=' -f2)
}

@test "Invalid command when option is before command" {
    run cache.sh --path=$TEST_DIR enable     
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "No command or option." ]]
    [[ "${lines[1]}" == "Try 'mlab cache -h' for more information." ]]
}

@test "Invalid enable cache without url options" {
    run cache.sh enable
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "No url option." ]]
    [[ "${lines[1]}" == "Try 'mlab cache -h' for more information." ]]
    run cache.sh enable --path=$TEST_DIR
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "No url option." ]]
    [[ "${lines[1]}" == "Try 'mlab cache -h' for more information." ]]
}

@test "Enable cache with url options " {
    run cache.sh enable --url="http://teste.url"

    [[ "${status}" -eq 0 ]]
    [[ -d "$CACHE_DIR_CONF" ]]
    [[ -f "$CACHE_FILE_CONF" ]]
    
    path_value=$(get_config PATH)
    url_value=$(get_config URL)

    [[ "$path_value" == "$CACHE_DIR_CONF" ]]
    [[ "$url_value" == "http://teste.url" ]]
}

@test "Enable with path and url option" {
    run cache.sh enable --path=$TEST_DIR --url="http://teste.url"
    [[ "${status}" -eq 0 ]]
    [[ -d "$CACHE_DIR_CONF" ]]
    [[ -f "$CACHE_FILE_CONF" ]]

    [[ -d "$TEST_DIR" ]]
    
    path_value=$(get_config PATH)
    url_value=$(get_config URL)

    [[ "$path_value" == "$TEST_DIR" ]]
    [[ "$url_value" == "http://teste.url" ]]
}
