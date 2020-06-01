#!/usr/bin/env bash

set -e

MODULE=${1:?}
SCRIPT=${2:?}

ACTION=discovery

: ${SCRIPTS_DIR:=$PMPY_SCRIPTS_DIR} \
  ${SCRIPTS_DIR:?}

if
    flock -ns 3
then
   $SCRIPTS_DIR/collect.sh $MODULE \
                           $ACTION \
                           $SCRIPT
fi

   $SCRIPTS_DIR/send_$ACTION.sh  $MODULE \
                                 $SCRIPT
