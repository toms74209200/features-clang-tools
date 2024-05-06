#!/bin/bash

set -e

source dev-container-features-test-lib

check "clang-tidy verson" clang-tidy --version
check "clang-format verson" clang-format --version

reportResults
