#!/bin/bash
RED=`tput setaf 1`
GREEN=`tput setaf 2`
NC=`tput sgr0`
HOST_REGEX='(https?:\/\/(www\.)?[-a-zA-Z0-9]{2,256}\.[a-z]{2,6})|((https?:\/\/)?([0-9]{1,3}\.){3}([0-9]{1,3}))(\:?[0-9]{1,5})?(\/)?'
GENSEED="$(docker run --rm crypto/core src/stellar-core gen-seed)"
SEED=${GENSEED:13:56}
PUBLIC=${GENSEED:78:56}
IS_VALIDATOR='false'
VALIDATOR_KEY=''
COMISSION_KEY=''
GENERAL_KEY=''
PEERS=''
RIAK_HOST=''
RIAK_USER=''
RIAK_PASS=''
HOME_DOMAIN=''

MASTER_SEED=$(grep MASTER_SEED ~/gurosh/seeds.txt | xargs)
IFS='=' read -ra MASTER_SEED <<< "$MASTER_SEED"
MASTER_SEED=${MASTER_SEED[1]}

MASTER_PUBLIC_KEY=$(grep MASTER_PUBLIC_KEY ~/gurosh/seeds.txt | xargs)
IFS='=' read -ra MASTER_PUBLIC_KEY <<< "$MASTER_PUBLIC_KEY"
MASTER_PUBLIC_KEY=${MASTER_PUBLIC_KEY[1]}

COMISSION_PUBLIC_KEY=$(grep FEE_AGENT_PUBLIC_KEY ~/gurosh/seeds.txt | xargs)
IFS='=' read -ra COMISSION_PUBLIC_KEY <<< "$COMISSION_PUBLIC_KEY"
COMISSION_PUBLIC_KEY=${COMISSION_PUBLIC_KEY[1]}

COMISSION_SEED=$(grep FEE_AGENT_SEED ~/gurosh/seeds.txt | xargs)
IFS='=' read -ra COMISSION_SEED <<< "$COMISSION_SEED"
COMISSION_SEED=${COMISSION_SEED[1]}

NODE_PUBLIC_KEY=$(grep VALIDATOR_PUBLIC_KEY ~/gurosh/seeds.txt | xargs)
IFS='=' read -ra NODE_PUBLIC_KEY <<< "$NODE_PUBLIC_KEY"
NODE_PUBLIC_KEY=${NODE_PUBLIC_KEY[1]}

NODE_SEED=$(grep VALIDATOR_SEED ~/gurosh/seeds.txt | xargs)
IFS='=' read -ra NODE_SEED <<< "$NODE_SEED"
NODE_SEED=${NODE_SEED[1]}

RIAK_PROTOCOL_HOST_PORT=$(grep RIAK_PROTOCOL_HOST_PORT ~/gurosh/seeds.txt | xargs)
IFS='=' read -ra RIAK_PROTOCOL_HOST_PORT <<< "$RIAK_PROTOCOL_HOST_PORT"
RIAK_PROTOCOL_HOST_PORT=${RIAK_PROTOCOL_HOST_PORT[1]}

HOME_DOMAIN=$(grep HOME_DOMAIN ~/gurosh/seeds.txt | xargs)
IFS='=' read -ra HOME_DOMAIN <<< "$HOME_DOMAIN"
HOME_DOMAIN=${HOME_DOMAIN[1]}

HOST_IP=$(grep HOST_IP ~/gurosh/seeds.txt | xargs)
IFS='=' read -ra HOST_IP <<< "$HOST_IP"
HOST_IP=${HOST_IP[1]}

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
        echo "${RED}Unknown option: $i ${NC}"
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
    echo "${GREEN}MASTER Node Seed : ${MASTER_SEED} ${NC}"
    
        SEED=${MASTER_SEED}
        PUBLIC=${MASTER_PUBLIC_KEY}
        break
done

while true
do
    echo "${GREEN}Fee Agent Public Key:${COMISSION_PUBLIC_KEY} ${NC}"
        COMISSION_KEY=${COMISSION_PUBLIC_KEY}
        break
done

while true
do
    echo "${GREEN}Validator Public Key: ${NODE_PUBLIC_KEY} ${NC}"
        VALIDATOR_KEY=${NODE_PUBLIC_KEY}
        break
done

while true
do
    PEERS="[\"$HOST_IP:11635\", \"$HOST_IP:11645\"]"
    echo "${GREEN}Add preferred peer : $PEERS${NC}"
    break
done

while true
do
    echo "${GREEN}Riak Host: ${RIAK_PROTOCOL_HOST_PORT} ${NC}"
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
    read -ra key -p "${GREEN}Riak username [leave empty to skip]:${NC} "
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

rm -f ./.core-cfg
echo $'\n'
echo "**************************************************************************"
echo "${GREEN}Public Key: $PUBLIC ${NC}" 
echo "**************************************************************************"

echo "RIAK_HOST=$RIAK_HOST" >> ./.core-cfg
if [[ $RIAK_USER != '' ]]; then
    echo "RIAK_USER=$RIAK_USER" >> ./.core-cfg
fi
if [[ $RIAK_PASS != '' ]]; then
    echo "RIAK_PASS=$RIAK_PASS" >> ./.core-cfg
fi
echo "NODE_SEED=$SEED" >> ./.core-cfg
echo "NODE_IS_VALIDATOR=$IS_VALIDATOR" >> ./.core-cfg
echo "ONE_KEY=$VALIDATOR_KEY" >> ./.core-cfg
echo "TWO_KEY=$COMISSION_KEY" >> ./.core-cfg

if [[ $PEERS != '' ]]; then
    echo "PREFERRED_PEERS=${PEERS}" >> ./.core-cfg
fi

echo "STELLAR_PEER_PORT=11625" >> ./.core-cfg
echo "STELLAR_HTTP_PORT=11626" >> ./.core-cfg
echo "NODE_NAME=core" >> ./.core-cfg
echo "VALIDATORS=$VALIDATOR_KEY" >> ./.core-cfg
echo "HOME_DOMAIN=$HOME_DOMAIN" >> ./.core-cfg

echo "BANK_MASTER_KEY=$MASTER_PUBLIC_KEY"   >> ./.hz-cfg
echo "BANK_COMMISSION_KEY=$COMISSION_PUBLIC_KEY"   >> ./.hz-cfg