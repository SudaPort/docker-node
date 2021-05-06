#!/bin/bash

HOST_REGEX='(https?:\/\/(www\.)?[-a-zA-Z0-9]{2,256}\.[a-z]{2,6})|((https?:\/\/)?([0-9]{1,3}\.){3}([0-9]{1,3}))(\:?[0-9]{1,5})?(\/)?'
GENSEED="$(docker run --rm crypto/core src/stellar-core gen-seed)"
SEED=${GENSEED:13:56}
PUBLIC=${GENSEED:78:56}
IS_VALIDATOR='false'
MASTER_KEY=''
COMISSION_KEY=''
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
    read -ra key -p "${GREEN}VALIDATOR Node Seed (leave empty to generate): ${NC}"
    if [[ $key == '' ]]; then
        break
    fi

    # valid="$(docker run --rm crypto/core src/stellar-core --checkseed $key)"
    # if [[ $valid == 0 ]]; then
        # echo "Error: seed is invalid. Try again."
    # else
        SEED=$key
        PUBLIC=$valid
        break
    # fi
done

while true
do
    read -ra key -p "${GREEN}Master's Public Key: ${NC}"
        MASTER_KEY=$key
        break
done

while true
do
    read -ra key -p "${GREEN}Fee Agent's Public Key: ${NC}"
        COMISSION_KEY=$key
        break
done

while true
do
    read -ra peer -p "${GREEN}Add preferred peer (host-ip:11625  host-ip:11635 empty line to finish): ${NC}"
    if [[ $peer == '' ]]; then
        break
    fi

    peer=${peer,,}
    if [[ ! $peer =~ $HOST_REGEX ]]; then
        echo "${RED}Error: Peer address [$peer] is not valid!${NC}"
        continue
    fi


    peer=${peer#http://}
    peer=${peer#https://}
    peer=${peer%/}
    peer=${peer// }
    exists="$(strpos \"$PEERS\" \"$peer\")"
    if [[ $exists != '' ]]; then
        echo "${RED}Error: Peer address [$peer] already added!${NC}"
        continue
    fi

    echo "${GREEN} $peer added to preferred!${NC}"

    PEERS+=\"$peer:11625\",
done

while true
do
    read -ra peer -p "${GREEN}Riak Host: (with protocol and port)${NC}"
    peer=${peer,,}

    if [[ ! $peer =~ $HOST_REGEX ]]
    then
        echo "${RED}Error: riak host [$peer] is not valid!${NC}"
        continue
    fi
    peer=${peer%%+(/)}

    RIAK_HOST=${peer// }
    break
done

while true
do
    read -ra key -p "${GREEN} Riak username [leave empty to skip]: ${NC}"
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

rm -f ./.core2-cfg
echo $'\n'
echo "**************************************************************************"
echo "${GREEN}Public Key: $PUBLIC ${NC}" 
echo "**************************************************************************"

echo "RIAK_HOST=$RIAK_HOST" >> ./.core2-cfg
if [[ $RIAK_USER != '' ]]; then
    echo "RIAK_USER=$RIAK_USER" >> ./.core2-cfg
fi
if [[ $RIAK_PASS != '' ]]; then
    echo "RIAK_PASS=$RIAK_PASS" >> ./.core2-cfg
fi
echo "NODE_SEED=$SEED" >> ./.core2-cfg
echo "NODE_IS_VALIDATOR=$IS_VALIDATOR" >> ./.core2-cfg
echo "ONE_KEY=$MASTER_KEY" >> ./.core2-cfg
echo "TWO_KEY=$COMISSION_KEY" >> ./.core2-cfg

if [[ $PEERS != '' ]]; then
    echo "PREFERRED_PEERS=[${PEERS::-1}]" >> ./.core2-cfg
fi


echo "STELLAR_PEER_PORT=11645" >> ./.core2-cfg
echo "STELLAR_HTTP_PORT=11646" >> ./.core2-cfg
echo "NODE_NAME=validator" >> ./.core2-cfg