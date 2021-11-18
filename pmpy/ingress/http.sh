set -ea

: ${SCRIPTS_DIR:=$PMPY_SCRIPTS_DIR} \
  ${SCRIPTS_DIR:?}

`jq '.|to_entries|.[]
     |.key + @sh "=\(.value)"' -r`

> /dev/null \
$SCRIPTS_DIR/process.sh &

echo 'Status: 204'
