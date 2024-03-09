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

@test "Invalid command without second parameter" {
    run cache.sh enable --url="http://teste.url" --path=$TEST_DIR
    [[ "${status}" -eq 0 ]]
    [[ -f "$CACHE_FILE_CONF" ]]

    run cache.sh get
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "One o more paramaters failed." ]]
    [[ "${lines[1]}" == "Try 'mlab cache -h' for more information." ]]
}

@test "Get cache without enable before " {

    rm -r "$CACHE_DIR_CONF" 2> /dev/null

    run cache.sh get XYZ
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Enable cache first." ]]
    [[ "${lines[1]}" == "Try 'mlab cache -h' for more information." ]]
}

@test "Get cache with key " {
    
    run cache.sh enable --url="http://teste.url" --path=$TEST_DIR

    KEY="123/XYZ"
    mkdir -p $(dirname "$TEST_DIR/$KEY")
    touch "$TEST_DIR/$KEY"

    run cache.sh get $KEY 
    [[ "${status}" -eq 0 ]]
    [[ "${lines[0]}" == "$TEST_DIR/$KEY" ]]

}

@test "Get not exist key " {
    
    run cache.sh enable --url="http://teste.url" --path=$TEST_DIR

    KEY="123/XYZ"

    run cache.sh get $KEY 
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Cache not found: $TEST_DIR/$KEY" ]]

}
