#!/bin/sh

source_hook() {
    if [ "${#}" -ne 2 ]; then
        echo "Usage: ${0} <pre|post> <hook-name>"
        exit 1
    fi

    SCRIPT_NAME="build-hooks/${1}-${2}.sh"
    if [ -f "${SCRIPT_NAME}" ]; then
        . "${SCRIPT_NAME}"
    fi
}
