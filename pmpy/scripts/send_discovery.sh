ITEM_KEY=pmpy.discovery[$MODULE/$SCRIPT]

if [ ! -s $WORK_DIR/$DATA_FILE \
   ]
then
    terminate_on_send_error 3
fi

if
 > /dev/null \
    diff  $WORK_DIR/$DATA_FILE \
          $WORK_DIR/$SENT_DATA_FILE
then
    if [    $WORK_DIR/$DATA_FILE \
        -ef $WORK_DIR/$SENT_DATA_FILE \
       ]
    then
        exit
    else
        terminate_successfully
    fi
fi

if 
 > /dev/null \
    zabbix_sender -z $ZABBIX_SERVER_HOST \
                  -p $ZABBIX_SERVER_PORT \
                  -s $HOSTNAME -k $ITEM_KEY -o "`cat $WORK_DIR/$DATA_FILE`"
then
    terminate_successfully
else
    terminate_on_send_error $?
fi
