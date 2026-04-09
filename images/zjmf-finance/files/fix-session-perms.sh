#!/bin/sh
set -eu
SESSION_DIR="${SESSION_DIR:-/tmp/session}"
mkdir -p "${SESSION_DIR}" || true
chmod 777 "${SESSION_DIR}" || true
