#!/usr/bin/env bash

set -e

: ${RESULT_FILE:?}
: ${MODULES_DIR:=$PMPY_MODULES_DIR} \
  ${MODULES_DIR:?}

ACTION_INTERVAL=86400

 > $RESULT_FILE \
jq -s  "{data:.}" <(
                    find $MODULES_DIR  -mindepth 3 -maxdepth 3 -type f \
                                       -printf %P\\n | awk -F/ '
                                                                 $2~"^init|discovery|metrics$"
                                                               ' | jq -R {\"{#ID}\":.}
                   )

touch -d $ACTION_INTERVAL\ sec \
         $RESULT_FILE
