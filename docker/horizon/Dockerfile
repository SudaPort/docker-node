FROM golang:1.6

RUN apt-get update && apt update && apt-get install -y \
	git \
	&& go get github.com/constabulary/gb/...

WORKDIR /vhosts

RUN	git clone -b main --depth 1 https://github.com/sudaport/horizon.git horizon

WORKDIR /vhosts/horizon

RUN gb vendor restore
RUN gb build

COPY ./entrypoint.sh /

CMD ["/entrypoint.sh"]
