FROM    alpine:3.12

COPY    --from=busybox:1.31.1-musl \
       /bin/busybox /bin/

RUN     apk add   --no-cache \
            bash jq coreutils \
            zabbix-utils findutils

ENV     PMPY_SCRIPTS_DIR=/pmpy/scripts \
        PMPY_MODULES_DIR=/pmpy/modules \
        PMPY_RESULTS_DIR=/data/results \
        PMPY_STORAGE_DIR=/data/storage \
                                       \
        PMPY_MODULES_PARALLELISM=3     \
        PMPY_ACTIONS_PARALLELISM=3     \
                                       \
        PMPY_LISTEN_IP=0               \
        PMPY_LISTEN_PORT=10051

ENTRYPOINT exec tcpsvd $PMPY_LISTEN_IP $PMPY_LISTEN_PORT \
                       $PMPY_SCRIPTS_DIR/process.sh

ADD    /pmpy /pmpy
