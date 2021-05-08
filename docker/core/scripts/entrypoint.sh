#!/bin/bash

DB_NAME="stellar"

touch core.cfg
echo "DATABASE=\"postgresql://dbname=$DB_NAME$NODE_NAME user=$PGUSER password=$PGPASSWORD host=$PGHOST\"" >> core.cfg
echo "" >> core.cfg
echo "HTTP_PORT=$STELLAR_HTTP_PORT"                                             >> core.cfg
echo "" >> core.cfg
echo "PEER_PORT=$STELLAR_PEER_PORT"                                             >> core.cfg
echo "" >> core.cfg
echo "PUBLIC_HTTP_PORT=true"                                                    >> core.cfg
echo "" >> core.cfg
echo "PREFERRED_PEER_KEYS=[\"$ONE_KEY\", \"$TWO_KEY\"]"                         >> core.cfg
echo "" >> core.cfg
# echo "BANK_MASTER_KEY=\"$BANK_MASTER_KEY\""                                   >> core.cfg
# echo "BANK_COMMISSION_KEY=\"$BANK_COMMISSION_KEY\""                           >> core.cfg
echo "NETWORK_PASSPHRASE=\"$NETWORK_PASSPHRASE\""                               >> core.cfg
echo "" >> core.cfg
echo "NODE_SEED=\"$NODE_SEED\""                                                 >> core.cfg
echo "" >> core.cfg
echo "NODE_IS_VALIDATOR=$NODE_IS_VALIDATOR"                                     >> core.cfg
echo "" >> core.cfg
echo "CATCHUP_COMPLETE=true"                                                    >> core.cfg
echo "" >> core.cfg
echo "FAILURE_SAFETY=0"                                                         >> core.cfg
echo "" >> core.cfg
echo "UNSAFE_QUORUM=true"                                                       >> core.cfg
echo "" >> core.cfg

if [ ! -z "$PREFERRED_PEERS" ]; then
    echo "KNOWN_PEERS=$PREFERRED_PEERS"                                         >> core.cfg
    echo "PREFERRED_PEERS=$PREFERRED_PEERS"                                     >> core.cfg
fi

echo "" >> core.cfg
if [[ $NODE_IS_VALIDATOR == 'true' ]]; then
    echo "NODE_HOME_DOMAIN=\"${HOME_DOMAIN}\""                                 >> core.cfg
    echo "" >> core.cfg
fi 

echo "[[HOME_DOMAINS]]"                                                        >> core.cfg
echo "HOME_DOMAIN=\"$HOME_DOMAIN\""                                            >> core.cfg
echo "QUALITY=\"MEDIUM\""                                                      >> core.cfg
echo "" >> core.cfg

if [[ $NODE_IS_VALIDATOR != 'true' ]]; then
 echo "[[VALIDATORS]]"                                                         >> core.cfg
 echo "NAME=\"validatornode\""                                                 >> core.cfg
#  echo "QUALITY=\"MEDIUM\""                                                   >> core.cfg
 echo "HOME_DOMAIN=\"$HOME_DOMAIN\""                                           >> core.cfg
 echo "PUBLIC_KEY=\"${VALIDATORS}\""                                           >> core.cfg
#  echo "ADDRESS=\"${HOME_DOMAIN}:11645\""                                     >> core.cfg
fi
chmod u+x /scripts/riakget.sh
chmod u+x /scripts/riakput.sh
echo "" >> core.cfg
echo "[HISTORY.riak]"                                                                          >> core.cfg
echo "get=\"./scripts/riakget.sh $RIAK_HOST $RIAK_BUCKET {0} {1} $RIAK_USER $RIAK_PASS\""      >> core.cfg
echo "put=\"./scripts/riakput.sh $RIAK_HOST $RIAK_BUCKET {0} {1} $RIAK_USER $RIAK_PASS\""      >> core.cfg
echo "mkdir=\"mkdir -p {0}\""                                                                  >> core.cfg
echo "" >> core.cfg
# echo "[HISTORY.azure]"                                                                      >> core.cfg
# echo "get=\"***\""                                                                          >> core.cfg
# echo "put=\"***\""                                                                          >> core.cfg

#echo "[HISTORY.local]"                                                                       >> core.cfg
#echo "get=\"cp /tmp/stellar-core/history/vs/{0} {1}\""                                       >> core.cfg
#echo "put=\"cp {0} /tmp/stellar-core/history/vs/{1}\""                                       >> core.cfg
#echo "mkdir=\"mkdir -p /tmp/stellar-core/history/vs/{0}\""                                   >> core.cfg

# Comment out if not new network
src/stellar-core --conf core.cfg
if [$NODE_NAME==core]; then
        src/stellar-core new-hist riak
        # src/stellar-core new-hist azure
fi
src/stellar-core new-db

# Old code
# TABLE_EXISTS=`psql -d $DB_NAME -A -c "SELECT count(*) from information_schema.tables WHERE table_name = 'accounts'" | head -2 | tail -1`

# if [[ $TABLE_EXISTS == 0 ]]; then
#     echo "Initializing Dabatase"
#     # --newhist flag should run prior to new-db!!! 
#     #src/stellar-core --conf core.cfg --newhist local
#  src/stellar-core --conf core.cfg
#     if [[ $NODE_IS_VALIDATOR == 'true' ]]; then 
#         src/stellar-core new-hist riak
#         # src/stellar-core new-hist azure
#     fi
#  src/stellar-core new-db
# elif [[ $TABLE_EXISTS == 1 ]]; then
#     echo "DB Exists. Starting Core"
# else
#     echo "Core: No connection to postgres. Waiting..."
#     exit
# fi

# src/stellar-core --conf core.cfg
