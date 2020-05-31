#!/usr/bin/env bash

set -e

MODULE=${1:?}

: ${SCRIPTS_DIR:=$PMPY_SCRIPTS_DIR} \
  ${SCRIPTS_DIR:?}

: ${MODULES_DIR:=$PMPY_MODULES_DIR} \
  ${MODULES_DIR:?}

: ${SCRIPTS_PARALLELISM:=$PMPY_SCRIPTS_PARALLELISM} \
  ${SCRIPTS_PARALLELISM:=3}

export PMPY_MODULE_ROOT_DIR=$MODULES_DIR/$MODULE
export PMPY_MODULE_STATE_DIR=$PMPY_MODULE_ROOT_DIR/state

cd $PMPY_MODULE_ROOT_DIR

exec 3>lock

flock -n 3 || :

for actions in  init \
               'discovery
                metrics' ; do
    echo $actions | xargs -n1 sh -c "
                     2>/dev/null \
                        find \$0 -mindepth 1 -maxdepth 1  \
                                 -type f     -printf %P\\\n | \
                        xargs -rn1 -P $SCRIPTS_PARALLELISM $SCRIPTS_DIR/process_module_\$0.sh $MODULE
                                    "
done
