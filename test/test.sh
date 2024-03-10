#!/usr/bin/env bash
# https://bats-core.readthedocs.io/en/stable/tutorial.html

export PROJECT_ROOT="$( cd "$(pwd)/.." >/dev/null 2>&1 && pwd )"

bats/bin/bats -p cmd/cache

bats/bin/bats -p cmd/getopt.bats