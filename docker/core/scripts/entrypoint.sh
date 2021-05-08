#!/bin/bash

DB_NAME="stellar"

rm -f $HOME/core.cfg
echo "DATABASE=\"postgresql://dbname=$DB_NAME$NODE_NAME user=$PGUSER password=$PGPASSWORD host=$PGHOST\"" >> $HOME/core.cfg
echo "" >> $HOME/core.cfg
echo "HTTP_PORT=$STELLAR_HTTP_PORT"                                             >> $HOME/core.cfg
echo "" >> $HOME/core.cfg
echo "PEER_PORT=$STELLAR_PEER_PORT"                                             >> $HOME/core.cfg
echo "" >> $HOME/core.cfg
echo "PUBLIC_HTTP_PORT=true"                                                    >> $HOME/core.cfg
echo "" >> $HOME/core.cfg
echo "PREFERRED_PEER_KEYS=[\"$ONE_KEY\", \"$TWO_KEY\"]"                         >> $HOME/core.cfg
echo "" >> $HOME/core.cfg
# echo "BANK_MASTER_KEY=\"$BANK_MASTER_KEY\""                                   >> $HOME/core.cfg
# echo "BANK_COMMISSION_KEY=\"$BANK_COMMISSION_KEY\""                           >> $HOME/core.cfg
echo "NETWORK_PASSPHRASE=\"$NETWORK_PASSPHRASE\""                               >> $HOME/core.cfg
echo "" >> $HOME/core.cfg
echo "NODE_SEED=\"$NODE_SEED\""                                                 >> $HOME/core.cfg
echo "" >> $HOME/core.cfg
echo "NODE_IS_VALIDATOR=$NODE_IS_VALIDATOR"                                     >> $HOME/core.cfg
echo "" >> $HOME/core.cfg
echo "CATCHUP_COMPLETE=true"                                                    >> $HOME/core.cfg
echo "" >> $HOME/core.cfg
echo "FAILURE_SAFETY=0"                                                         >> $HOME/core.cfg
echo "" >> $HOME/core.cfg
echo "UNSAFE_QUORUM=true"                                                       >> $HOME/core.cfg
echo "" >> $HOME/core.cfg

if [ ! -z "$PREFERRED_PEERS" ]; then
    echo "KNOWN_PEERS=$PREFERRED_PEERS"                                         >> $HOME/core.cfg
    echo "PREFERRED_PEERS=$PREFERRED_PEERS"                                     >> $HOME/core.cfg
fi

echo "" >> $HOME/core.cfg
if [[ $NODE_IS_VALIDATOR == 'true' ]]; then
    echo "NODE_HOME_DOMAIN=\"${HOME_DOMAIN}\""                                 >> $HOME/core.cfg
    echo "" >> $HOME/core.cfg
fi 

echo "[[HOME_DOMAINS]]"                                                        >> $HOME/core.cfg
echo "HOME_DOMAIN=\"$HOME_DOMAIN\""                                            >> $HOME/core.cfg
echo "QUALITY=\"MEDIUM\""                                                      >> $HOME/core.cfg
echo "" >> $HOME/core.cfg

if [[ $NODE_IS_VALIDATOR != 'true' ]]; then
 echo "[[VALIDATORS]]"                                                         >> $HOME/core.cfg
 echo "NAME=\"validatornode\""                                                 >> $HOME/core.cfg
#  echo "QUALITY=\"MEDIUM\""                                                   >> $HOME/core.cfg
 echo "HOME_DOMAIN=\"$HOME_DOMAIN\""                                           >> $HOME/core.cfg
 echo "PUBLIC_KEY=\"${VALIDATORS}\""                                           >> $HOME/core.cfg
#  echo "ADDRESS=\"${HOME_DOMAIN}:11645\""                                     >> $HOME/core.cfg
fi
echo "" >> $HOME/core.cfg
echo "[HISTORY.riak]"                                                           >> $HOME/core.cfg
echo "get=\"/scripts/riakget.sh $RIAK_HOST $RIAK_BUCKET {0} {1} $RIAK_USER $RIAK_PASS\""      >> $HOME/core.cfg
echo "put=\"/scripts/riakput.sh $RIAK_HOST $RIAK_BUCKET {0} {1} $RIAK_USER $RIAK_PASS\""      >> $HOME/core.cfg
echo "mkdir=\"mkdir -p {0}\""                                                                 >> $HOME/core.cfg
#echo "[HISTORY.local]"                                                                        >> $HOME/core.cfg
#echo "get=\"cp /tmp/stellar-core/history/vs/{0} {1}\""                                        >> $HOME/core.cfg
#echo "put=\"cp {0} /tmp/stellar-core/history/vs/{1}\""                                        >> $HOME/core.cfg
#echo "mkdir=\"mkdir -p /tmp/stellar-core/history/vs/{0}\""                                    >> $HOME/core.cfg


TABLE_EXISTS=`psql -d $DB_NAME -A -c "SELECT count(*) from information_schema.tables WHERE table_name = 'accounts'" | head -2 | tail -1`

if [[ $TABLE_EXISTS == 0 ]]; then
    echo "Initializing Dabatase"
    # --newhist flag should run prior to new-db!!! 
    #src/stellar-core --conf $HOME/core.cfg --newhist local

    if [[ $NODE_IS_VALIDATOR == 'true' ]]; then
        # src/stellar-core http-command stellar-core --conf $HOME/core.cfg 
        # src/stellar-core newhist riak
        src/stellar-core --conf $HOME/core.cfg newhist riak
    fi
    # src/stellar-core http-command stellar-core --conf $HOME/core.cfg 
    # src/stellar-core new-db
    src/stellar-core --conf $HOME/core.cfg new-db
elif [[ $TABLE_EXISTS == 1 ]]; then
    echo "DB Exists. Starting Core"
else
    echo "Core: No connection to postgres. Waiting..."
    exit
fi

if [[ $NODE_IS_VALIDATOR == 'true' ]]; then
    # src/stellar-core http-command stellar-core --conf $HOME/core.cfg 
    # src/stellar-core new-db force-scp
    src/stellar-core --conf $HOME/core.cfg force-scp 
fi
# src/stellar-core http-command stellar-core --conf $HOME/core.cfg
src/stellar-core --conf $HOME/core.cfg 

