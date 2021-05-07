#!/bin/bash
RED=`tput setaf 1`
GREEN=`tput setaf 2`
NC=`tput sgr0`
HOST_REGEX='(https?:\/\/(www\.)?[-a-zA-Z0-9]{2,256}\.[a-z]{2,6})|((https?:\/\/)?([0-9]{1,3}\.){3}([0-9]{1,3}))(\:?[0-9]{1,5})?(\/)?'
GENSEED="$(docker run --rm crypto/core src/stellar-core gen-seed)"
SEED=${GENSEED:13:56}
PUBLIC=${GENSEED:78:56}
IS_VALIDATOR='false'
MASTER_KEY=''
VALIDATOR_KEY=''
GENERAL_KEY=''
PEERS=''
RIAK_HOST=''
RIAK_USER=''
RIAK_PASS=''

# Parse args
for i in "$@"
do
case $i in
    # -s=*|--searchpath=*)
    --is-validator)
    IS_VALIDATOR="true"
    shift
    ;;
    *)
        echo "Unknown option: $i"
        exit
    ;;
esac
done

strpos()
{
    local str=${1}
    local offset=${3}

    if [ -n "${offset}" ]; then
        str=`substr "${str}" ${offset}`
    else
        offset=0
    fi

    str=${str/${2}*/}

    if [ "${#str}" -eq "${#1}" ]; then
        return 0
    fi

    echo $((${#str}+${offset}))
}

while true
do
    echo "${GREEN}FEE AGENT Node Seed : ${COMISSION_SEED} ${NC}"
        SEED= ${COMISSION_SEED}
        PUBLIC=${COMISSION_PUBLIC_KEY}
        break
done

while true
do
    echo "${GREEN}Master's Public Key: ${MASTER_PUBLIC_KEY} ${NC}"
        MASTER_KEY=${MASTER_PUBLIC_KEY}
        break
done

while true
do
    echo "${GREEN}Validator's Public Key: ${NODE_PUBLIC_KEY} ${NC}"
        VALIDATOR_KEY=${NODE_PUBLIC_KEY}
        break
done

while true
do
    PEERS="[\"core:11625\", \"validator:11625\"]"
    echo "${GREEN}Add preferred peer : $PEERS ${NC}"
    break
done

while true
do
    read -ra peer -p "${GREEN} Riak Host: ${RIAK_PROTOCOL_HOST_PORT} ${NC}"
    peer=${RIAK_PROTOCOL_HOST_PORT}

    if [[ ! $peer =~ $HOST_REGEX ]]
    then
        echo "${RED}Error: riak host [$peer] is not valid!${NC}"
        break
    fi
    peer=${peer%%+(/)}

    RIAK_HOST=${peer// }
    break
done

while true
do
    read -ra key -p "${GREEN}Riak username [leave empty to skip]: ${NC}"
    if [[ $key == '' ]]; then
        break
    fi

    RIAK_USER=$key
    while true
    do
        IFS= read -s  -p "${GREEN}Riak password: ${NC}" key
        if [[ $key != '' ]]; then
            RIAK_PASS=$key
            break 2
        fi

        echo "${RED}Password cannot be empty${NC}"
    done
done

rm -f ./.core1-cfg
echo $'\n'
echo "**************************************************************************"
echo "${GREEN}Public Key: $PUBLIC ${NC}" 
echo "**************************************************************************"

echo "RIAK_HOST=$RIAK_HOST" >> ./.core1-cfg
if [[ $RIAK_USER != '' ]]; then
    echo "RIAK_USER=$RIAK_USER" >> ./.core1-cfg
fi
if [[ $RIAK_PASS != '' ]]; then
    echo "RIAK_PASS=$RIAK_PASS" >> ./.core1-cfg
fi
echo "NODE_SEED=$SEED" >> ./.core1-cfg
echo "NODE_IS_VALIDATOR=$IS_VALIDATOR" >> ./.core1-cfg
echo "ONE_KEY=$MASTER_KEY" >> ./.core1-cfg
echo "TWO_KEY=$VALIDATOR_KEY" >> ./.core1-cfg

if [[ $PEERS != '' ]]; then
    echo "PREFERRED_PEERS=[${PEERS::-1}]" >> ./.core1-cfg
fi

echo "STELLAR_PEER_PORT=11625" >> ./.core1-cfg
echo "STELLAR_HTTP_PORT=11626" >> ./.core1-cfg
echo "NODE_NAME=fee" >> ./.core1-cfg
echo "VALIDATORS=$VALIDATOR_KEY" >> ./.core1-cfg
read -ra key -p "${GREEN}HOME DOMAIN: ${NC}"
        HOME_DOMAIN=$key
echo "HOME_DOMAIN=$HOME_DOMAIN" >> ./.core1-cfg