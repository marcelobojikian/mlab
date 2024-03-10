#!/usr/bin/env bash

_common_setup() {
    load "$PROJECT_ROOT/test/test_helper/bats-support/load"
    load "$PROJECT_ROOT/test/test_helper/bats-assert/load"  
    PATH="$PROJECT_ROOT/src:$PATH"
}

_path_setup() {
    load "$PROJECT_ROOT/test/test_helper/bats-support/load"
    load "$PROJECT_ROOT/test/test_helper/bats-assert/load"  
    PATH="$PROJECT_ROOT/src/${1}:$PATH"
}