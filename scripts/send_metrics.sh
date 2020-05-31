#!/usr/bin/env bash

set -e

MODULE=${1:?}
ACTION=metrics
SCRIPT=${2:?}

: ${ZABBIX_SERVER_HOST:?} \
  ${ZABBIX_SERVER_PORT:=10051}

: ${RESULTS_DIR:=$PMPY_RESULTS_DIR} \
  ${RESULTS_DIR:?}

ITEM_BEACON_KEY=pmpy.beacon[$MODULE/$ACTION/$SCRIPT]

RESULT_DATA_INTERFACE=$RESULTS_DIR/$MODULE/$ACTION/$SCRIPT/data.current

WORK_DIR=$RESULTS_DIR/$MODULE/$ACTION/$SCRIPT
mkdir -p $WORK_DIR

LOCK_FILE=send.to.$ZABBIX_SERVER_HOST.lock
DATA_FILE=send.to.$ZABBIX_SERVER_HOST.data

SENT_DATA_FILE=sent.to.$ZABBIX_SERVER_HOST.data
touch    $WORK_DIR/$SENT_DATA_FILE

exec     3>$WORK_DIR/$LOCK_FILE
flock -n 3

ln -f  $RESULT_DATA_INTERFACE \
       $WORK_DIR/$DATA_FILE

if
  [  ! $WORK_DIR/$DATA_FILE \
   -ef $WORK_DIR/$SENT_DATA_FILE \
  ]
then
    if 
    > /dev/null \
       zabbix_sender -z $ZABBIX_SERVER_HOST \
                     -p $ZABBIX_SERVER_PORT \
                     -s $HOSTNAME -i  $WORK_DIR/$DATA_FILE
    then
       DELIVERY_STATUS=$?
      
       mv    $WORK_DIR/$DATA_FILE \
             $WORK_DIR/$SENT_DATA_FILE
    else
       DELIVERY_STATUS=$?
    fi

    > /dev/null \
       zabbix_sender -z $ZABBIX_SERVER_HOST \
                     -p $ZABBIX_SERVER_PORT \
                     -s $HOSTNAME -k $ITEM_BEACON_KEY -o $DELIVERY_STATUS
fi
