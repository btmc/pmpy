#!/usr/bin/env bash

set -e

: ${RESULT_FILE:?}
: ${RESULTS_DIR:=$PMPY_RESULTS_DIR} \
  ${RESULTS_DIR:?}

ACTION_INTERVAL=21600

RESULT_TYPES='
                DIAG
                INFO
                DATA
             '

SAVE_NO_LESS_THAN_RECENT_N_FILES=10
SAVE_FILES_NO_OLDER_THAN_MINUTES=1440

find $RESULTS_DIR  -type     d \
                   -mindepth 3 \
                   -maxdepth 3 |
while read $WORK_DIR ; do
    for type in $RESULT_TYPES
             do
        dir=$WORK_DIR/$type
        
        if [ -d $dir ]
        then
            cat <(
                    ls -1t $dir |
                    tail +$((1+SAVE_NO_LESS_THAN_RECENT_N_FILES))
                 ) \
                <(
                    find   $dir \
                       -type  f \
                       -mmin +$SAVE_FILES_NO_OLDER_THAN_MINUTES
                 ) |
            sort | uniq -d | xargs -r rm
        fi
    done
done

touch -d $ACTION_INTERVAL\ sec \
         $RESULT_FILE
