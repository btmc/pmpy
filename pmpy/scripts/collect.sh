#!/usr/bin/env bash

set -e

MODULE=${1:?}
ACTION=${2:?}
SCRIPT=${3:?}

: ${MODULES_DIR:=$PMPY_MODULES_DIR} \
  ${MODULES_DIR:?}

: ${RESULTS_DIR:=$PMPY_RESULTS_DIR} \
  ${RESULTS_DIR:?}

WORK_DIR=$RESULTS_DIR/$MODULE/$ACTION/$SCRIPT

RESULT_TYPES='
                DIAG
                INFO
                DATA
             '

RESULT_FILE_PATTERN=`date +%F-%H-%M-%S`

declare -A RESULT_STORAGE_DIRS
declare -A RESULT_INTERFACES

for type in $RESULT_TYPES
         do
    RESULT_STORAGE_DIRS[$type]=$WORK_DIR/${type,,}

    mkdir -p ${RESULT_STORAGE_DIRS[$type]}

      RESULT_INTERFACES[$type]=$WORK_DIR/${type,,}.current
done
            
[ /dev/fd/3 -nt ${RESULT_INTERFACES[DATA]} ] || exit 0

          > ${RESULT_STORAGE_DIRS[INFO]}/$RESULT_FILE_PATTERN \
         2> ${RESULT_STORAGE_DIRS[DIAG]}/$RESULT_FILE_PATTERN \
RESULT_FILE=${RESULT_STORAGE_DIRS[DATA]}/$RESULT_FILE_PATTERN \
         $MODULES_DIR/$MODULE/$ACTION/$SCRIPT

for type in $RESULT_TYPES
         do
    if
      >/dev/null \
        diff -N ${RESULT_INTERFACES[$type]} \
              ${RESULT_STORAGE_DIRS[$type]}/$RESULT_FILE_PATTERN
    then
        ln -f ${RESULT_STORAGE_DIRS[$type]}/$RESULT_FILE_PATTERN \
                ${RESULT_INTERFACES[$type]}
        
        rm    ${RESULT_STORAGE_DIRS[$type]}/$RESULT_FILE_PATTERN
    else
        ln -f ${RESULT_STORAGE_DIRS[$type]}/$RESULT_FILE_PATTERN \
                ${RESULT_INTERFACES[$type]}
    fi
done
