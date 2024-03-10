#!/usr/bin/env bats

setup() {
    load "$PROJECT_ROOT/test/test_helper/bats_setup"
    _common_setup
}

teardown() {
    echo "status: ${status}"
    echo "output: ${output}"
}

debug() {
  status="$1"
  output="$2"
  if [[ ! "${status}" -eq "0" ]]; then
    echo "status: ${status}"
    echo "output: ${output}"
  fi
}

show_usage() {
    run command.sh $@    
    [[ "${status}" -eq 0 ]]
    [[ "${lines[0]}" == "Usage: mlab [OPTIONS] COMMAND"* ]]
}

show_version() {
    run command.sh $@ 
    [[ "${status}" -eq 0 ]]
    [[ "${lines[0]}" == "Version: "* ]]
}

invalid_option() {
    run command.sh $@
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Invalid option: "* ]]
    [[ "${lines[1]}" == "Try 'mlab -h' for more information." ]]
}

@test "Check invalid option" {
    invalid_option -E
    invalid_option -Ehv
    invalid_option -X
    invalid_option --XXXXXX
}

@test "Check help option" {
    show_usage 
    show_usage -h
    show_usage --help
    show_usage -hl
    show_usage -hl info
}

@test "Check version option" {
    show_version -v
    show_version --version
    show_version -vl
}
