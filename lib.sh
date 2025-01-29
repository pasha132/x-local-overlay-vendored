#!/usr/bin/env bash
#

set -ue

function eerror() {
  echo "::error:: $*" >&2
}

function einfo() {
  echo "::notice:: $*"
}

function die() {
  [ $# -eq 0 ] || eerror "$*"
  exitcode=2
  exit $exitcode
}
