FROM ubuntu:18.04

RUN apt update && apt-get update
RUN apt-get install -y clang-8 g++ pkg-config bison flex libpq-dev clang-format-8 perl libunwind-dev parallel gcc-7
RUN apt-get install dialog apt-utils \
    && apt-get install -y software-properties-common \
    && add-apt-repository ppa:ubuntu-toolchain-r/test \
    && apt-get update \
	&& apt-get install -y git curl build-essential autoconf automake libtool gcc-4.9 cpp-4.9 git postgresql

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
