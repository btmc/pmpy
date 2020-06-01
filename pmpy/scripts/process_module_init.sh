#!/usr/bin/env bash

set -e

MODULE=${1:?}
SCRIPT=${2:?}

: ${SCRIPTS_DIR:=$PMPY_SCRIPTS_DIR} \
  ${SCRIPTS_DIR:?}

: ${MODULES_DIR:=$PMPY_MODULES_DIR} \
  ${MODULES_DIR:?}

cd $MODULES_DIR/$MODULE/init

if
    flock -ns 3
then
  >/dev/null \
    find . -name $SCRIPT -mmin +0 -exec {} \;
fi
