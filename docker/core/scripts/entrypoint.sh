#!/bin/bash

DB_NAME="stellar"

touch $HOME/core.cfg
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
# chmod u+x /scripts/riakget.sh
# chmod u+x /scripts/riakput.sh
# echo "" >> $HOME/core.cfg
# echo "[HISTORY.riak]"                                                                          >> $HOME/core.cfg
# echo "get=\"./scripts/riakget.sh $RIAK_HOST $RIAK_BUCKET {0} {1} $RIAK_USER $RIAK_PASS\""      >> $HOME/core.cfg
# echo "put=\"./scripts/riakput.sh $RIAK_HOST $RIAK_BUCKET {0} {1} $RIAK_USER $RIAK_PASS\""      >> $HOME/core.cfg
# echo "mkdir=\"mkdir -p {0}\""                                                                  >> $HOME/core.cfg
echo "" >> $HOME/core.cfg

# Comment out if not new network
if [[ $NODE_NAME == 'core' ]]; then

        echo "[HISTORY.azure]"                                                                      >> $HOME/core.cfg
        echo "get=\"curl https://sandboxgurosh.blob.core.windows.net/sandboxhistory/{0} -o {1}\""   >> $HOME/core.cfg
        # echo "put=\"azure storage blob upload {0} sandboxgurosh {1}\""                              >> $HOME/core.cfg
        
        # src/stellar-core new-hist azure --conf $HOME/core.cfg
        # src/stellar-core new-db
        src/stellar-core new-db --conf $HOME/core.cfg

elif [[ $NODE_NAME == 'fee' ]]; then

        echo "[HISTORY.azure]"                                                                      >> $HOME/core.cfg
        echo "get=\"curl https://sandboxgurosh.blob.core.windows.net/sandboxhistory/{0} -o {1}\""   >> $HOME/core.cfg
        # echo "put=\  "azure storage blob upload {0} sandboxgurosh {1}\""                              >> $HOME/core.cfg
        
        src/stellar-core new-db --conf $HOME/core.cfg

elif [[ $NODE_NAME == 'validator' ]]; then

        echo "[HISTORY.azure]"                                                                      >> $HOME/core.cfg
        echo "get=\"curl https://sandboxgurosh.blob.core.windows.net/sandboxhistory/{0} -o {1}\""   >> $HOME/core.cfg
        echo "put=\"azure storage blob upload {0} sandboxgurosh {1}\""                              >> $HOME/core.cfg
 
        # src/stellar-core new-db --conf $HOME/core.cfg
        src/stellar-core new-db --conf $HOME/core.cfg
        src/stellar-core new-hist azure 
else 
       echo "Unknown node role..."
       exit
fi


src/stellar-core run --conf $HOME/core.cfg
