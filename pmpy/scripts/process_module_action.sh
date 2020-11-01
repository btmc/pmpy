#!/usr/bin/env bash

set -e

MODULE=${1:?}
ACTION=${2:?}
SCRIPT=${3:?}

: ${SCRIPTS_DIR:=$PMPY_SCRIPTS_DIR} \
  ${SCRIPTS_DIR:?}

if
    flock -ns 3
then
   $SCRIPTS_DIR/collect.sh $MODULE \
                           $ACTION \
                           $SCRIPT
fi

   $SCRIPTS_DIR/send.sh    $MODULE \
                           $ACTION \
                           $SCRIPT
