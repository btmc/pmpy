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
        terminate_successfully
    else
        terminate_on_send_error $?
    fi
fi
