FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install dialog 
RUN apt-get install -y apt-utils ca-certificates 2>&1
# RUN apt-utils 
RUN apt-get update 
RUN apt-get install -y software-properties-common 
RUN add-apt-repository ppa:ubuntu-toolchain-r/test 
RUN apt-get update 
RUN apt-get install -y build-essential curl pkg-config autoconf automake libtool bison flex libpq-dev clang libclang-dev clang++ gcc g++ cpp  postgresql git iproute2 procps lsb-release cmake libsodium18 libsodium-dev parallel libunwind-dev llvm libstdc++-7-dev clang-format-8 ccache

WORKDIR /vhosts

RUN git clone -b master https://github.com/stellar/stellar-core.git core

WORKDIR /vhosts/core

# g++-4.9 is required, so we need to replace symlink
RUN rm /usr/bin/g++ 
RUN ln -s /usr/bin/g++-4.9 /usr/bin/g++

RUN git submodule init 
RUN git submodule update 
RUN chmod u+w+r+x ./autogen.sh
RUN export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
RUN ./autogen.sh
RUN ./configure 
RUN make 
RUN make install

RUN mkdir /scripts

COPY ./scripts /scripts

CMD ["chmod", "+x", "/scripts/entrypoint.sh"]
