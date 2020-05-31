#!/usr/bin/env bash

set -e

MODULE=${1:?}
ACTION=${2:?}
SCRIPT=${3:?}

: ${MODULES_DIR:=$PMPY_MODULES_DIR} \
  ${MODULES_DIR:?}

: ${RESULTS_DIR:=$PMPY_RESULTS_DIR} \
  ${RESULTS_DIR:?}

: ${RESULT_DATA_RETENTION_MIN:=$PMPY_RESULT_DATA_RETENTION_MIN} \
  ${RESULT_DATA_RETENTION_MIN:=1440}

RESULT_DATA_DIR=$RESULTS_DIR/$MODULE/$ACTION/$SCRIPT/data
mkdir -p $RESULT_DATA_DIR

RESULT_DATA_FILE=`date +%F-%H-%M-%S`

RESULT_DATA_INTERFACE=$RESULTS_DIR/$MODULE/$ACTION/$SCRIPT/data.current

find   $MODULES_DIR/$MODULE/$ACTION -name $SCRIPT -mmin +0 \
                                    -exec sh -ec "
                                                  >$RESULT_DATA_DIR/$RESULT_DATA_FILE \
                                                    {}
                                                    ln -f  $RESULT_DATA_DIR/$RESULT_DATA_FILE \
                                                           $RESULT_DATA_INTERFACE
                                                 " \;

find   $RESULT_DATA_DIR -mmin +$RESULT_DATA_RETENTION_MIN \
                        -exec rm {} +
