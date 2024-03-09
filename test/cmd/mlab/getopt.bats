#!/usr/bin/env bats

setup() {
    load "$PROJECT_ROOT/test/test_helper/bats_setup"
    _path_setup proxmox
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
    run $@    
    [[ "${status}" -eq 0 ]]
    [[ "${lines[0]}" == "Usage: mlab [OPTIONS] COMMAND"* ]]
}

show_version() {
    run $@ 
    [[ "${status}" -eq 0 ]]
    [[ "${lines[0]}" == "Version: "* ]]
}

invalid_option() {
    run $@
    [[ "${status}" -eq 1 ]]
    [[ "${lines[0]}" == "Invalid option: "* ]]
    [[ "${lines[1]}" == "Try 'mlab -h' for more information." ]]
}

@test "Check invalid option" {
    invalid_option cmd.sh -E
    invalid_option cmd.sh -Ehv
    invalid_option cmd.sh -X
    invalid_option cmd.sh --XXXXXX
}

@test "Check help option" {
    show_usage cmd.sh
    show_usage cmd.sh -h
    show_usage cmd.sh --help
    show_usage cmd.sh -hl
    show_usage cmd.sh -hl info
}

@test "Check version option" {
    show_version cmd.sh -v
    show_version cmd.sh --version
    show_version cmd.sh -vl
}
