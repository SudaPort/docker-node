FROM ubuntu:18.04

RUN apt update && apt-get update
RUN apt-get install -y clang-8 g++ pkg-config bison flex libpq-dev clang-format-8 perl libunwind-dev parallel gcc-7
RUN apt-get install -y dialog 
RUN apt-get install -y apt-utils
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN DEBIAN_FRONTEND="noninteractive" TZ="Africa/Cairo" apt-get -y install tzdata
RUN apt-get install -y git curl build-essential autoconf automake libtool gcc-8 g++-8 cpp git postgresql
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 60
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 60
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
