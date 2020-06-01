#!/usr/bin/env bash

set -e

export  ZABBIX_SERVER_HOST=${TCPREMOTEADDR%:*}

export  PMPY_RUN_ID=`
                      cat /dev/urandom | base64 | \
                      tr -cd a-z0-9 | head -c8
                    `

: ${SCRIPTS_DIR:=$PMPY_SCRIPTS_DIR} \
  ${SCRIPTS_DIR:?}

: ${MODULES_DIR:=$PMPY_MODULES_DIR} \
  ${MODULES_DIR:?}

: ${MODULES_PARALLELISM:=$PMPY_MODULES_PARALLELISM} \
  ${MODULES_PARALLELISM:=3}

cd $MODULES_DIR

find . -mindepth 1 -maxdepth 1 \
       -type d -printf %P\\n | xargs -rn1 -P$MODULES_PARALLELISM \
                                            $SCRIPTS_DIR/process_module.sh
