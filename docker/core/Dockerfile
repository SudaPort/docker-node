FROM ubuntu:18.04

RUN apt update && apt-get update
RUN apt-get install -y git curl build-essential autoconf automake libtool cpp  postgresql clang clang-format pkg-config bison flex libpq-dev perl libunwind-dev parallel gcc g++
RUN apt-get install -y dialog 
RUN apt-get install -y apt-utils
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN DEBIAN_FRONTEND="noninteractive" TZ="Africa/Cairo" apt-get -y install tzdata
WORKDIR /vhosts

RUN git clone https://github.com/stellar/stellar-core.git

WORKDIR /vhosts/stellar-core

# g++-4.9 is required, so we need to replace symlink
RUN rm /usr/bin/g++ && ln -s /usr/bin/g++-4.9 /usr/bin/g++

RUN git submodule init \
	&& git submodule update \
	&& ./autogen.sh \
	&& ./configure \
	&& make \
	&& make install

RUN mkdir /scripts

COPY ./scripts /scripts

CMD ["/scripts/entrypoint.sh"]
