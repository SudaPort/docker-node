FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install dialog 
RUN apt-get install -y apt-utils ca-certificates 2>&1
# RUN apt-utils 
RUN apt-get update 
RUN apt-get install -y software-properties-common 
RUN add-apt-repository ppa:ubuntu-toolchain-r/test 
RUN apt-get update 
RUN apt-get install -y curl gcc-4.9 g++-4.9 cpp-4.9 git postgresql iproute2 procps lsb-release
RUN apt-get install -y build-essential cmake libsodium18 libsodium-dev pkg-config autoconf automake libtool bison flex parallel libpq-dev libunwind-dev clang-3.5 llvm-3.5
RUN apt-get -y install libstdc++-7-dev clang-format-8 ccache

WORKDIR /vhosts

RUN git clone -b main --depth 1 https://github.com/SudaPort/core.git core

WORKDIR /vhosts/core

# g++-4.9 is required, so we need to replace symlink
RUN rm /usr/bin/g++ 
RUN ln -s /usr/bin/g++-4.9 /usr/bin/g++

RUN git submodule init 
RUN git submodule update 
RUN chmod u+w+r+x ./autogen.sh
RUN ./autogen.sh
RUN ./configure 
RUN make 
RUN make install

RUN mkdir /scripts

COPY ./scripts /scripts

ENV DEBIAN_FRONTEND=
CMD ["chmod", "+x", "/scripts/entrypoint.sh"]
