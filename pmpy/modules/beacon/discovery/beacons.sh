#!/usr/bin/env bash

set -e

: ${MODULES_DIR:=$PMPY_MODULES_DIR} \
  ${MODULES_DIR:?}

ACTION_INTERVAL=86400


jq -s  "{data:.}" <(
                    find $MODULES_DIR  -mindepth 3 -maxdepth 3 -type f \
                                       -printf %P\\n | awk -F/ '
                                                                 $2=="metrics"
                                                               ' | jq -R  "{\"{#ID}\":.,\"{#TYPE}\":1}"
                   ) \
                  <(
                    find $MODULES_DIR  -mindepth 3 -maxdepth 3 -type f \
                                       -printf %P\\n | awk -F/ '
                                                                 $2=="discovery"
                                                               ' | jq -R  "{\"{#ID}\":.,\"{#TYPE}\":0}"
                   )

touch -d $ACTION_INTERVAL\ sec $0
