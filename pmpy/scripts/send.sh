#!/usr/bin/env bash

set -e

MODULE=${1:?}
ACTION=${2:?}
SCRIPT=${3:?}

: ${ZABBIX_SERVER_HOST:?} \
  ${ZABBIX_SERVER_PORT:=10051}

: ${RESULTS_DIR:=$PMPY_RESULTS_DIR} \
  ${RESULTS_DIR:?}

ITEM_KEY=pmpy.discovery[$MODULE/$SCRIPT]
ITEM_BEACON_KEY=pmpy.beacon[$MODULE/$ACTION/$SCRIPT]

WORK_DIR=$RESULTS_DIR/$MODULE/$ACTION/$SCRIPT

RESULT_DATA_INTERFACE=$WORK_DIR/data.current

LOCK_FILE=send.to.$ZABBIX_SERVER_HOST.lock
DATA_FILE=send.to.$ZABBIX_SERVER_HOST.data

SENT_DATA_FILE=sent.to.$ZABBIX_SERVER_HOST.data
touch      $WORK_DIR/$SENT_DATA_FILE

exec     3>$WORK_DIR/$LOCK_FILE
flock -n 3

ln -f  $RESULT_DATA_INTERFACE \
        $WORK_DIR/$DATA_FILE

terminate_successfully () {
    mv    $WORK_DIR/$DATA_FILE \
          $WORK_DIR/$SENT_DATA_FILE

 > /dev/null \
    zabbix_sender -z $ZABBIX_SERVER_HOST \
                  -p $ZABBIX_SERVER_PORT \
                  -s $HOSTNAME -k $ITEM_BEACON_KEY \
                               -o `stat -c%Y $WORK_DIR/$SENT_DATA_FILE`
    exit
}

terminate_on_send_error() {
 > /dev/null \
    zabbix_sender -z $ZABBIX_SERVER_HOST \
                  -p $ZABBIX_SERVER_PORT \
                  -s $HOSTNAME -k $ITEM_BEACON_KEY \
                               -o ${1?}
    exit
}

. ${0/./_$ACTION.}
