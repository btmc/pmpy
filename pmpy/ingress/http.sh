set -e

: ${SCRIPTS_DIR:=$PMPY_SCRIPTS_DIR} \
  ${SCRIPTS_DIR:?}

exec {ENV_FD}> `mktemp`

rm `readlink \
   /dev/fd/$ENV_FD`

  >& $ENV_FD \
jq '.|to_entries|.[]
     |.key + @sh "=\(.value)"' -r


set -a

. /dev/fd/$ENV_FD


> /dev/null \
$SCRIPTS_DIR/process.sh &

echo 'Status: 204'
