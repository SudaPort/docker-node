FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install dialog 
RUN apt-get install -y apt-utils
# RUN apt-utils 
RUN apt-get update 
RUN apt-get install -y software-properties-common 
# RUN add-apt-repository ppa:ubuntu-toolchain-r/test 
RUN apt-get update 
RUN apt-get install -y curl gcc g++ cpp git postgresql
RUN apt-get install -y build-essential pkg-config autoconf automake libtool bison flex libpq-dev clang

WORKDIR /vhosts

RUN git clone -b main --depth 1 https://github.com/SudaPort/core.git core

WORKDIR /vhosts/core

# g++-4.9 is required, so we need to replace symlink
RUN rm /usr/bin/g++ 
RUN ln -s /usr/bin/g++-4.9 /usr/bin/g++

RUN git submodule init 
RUN git submodule update 
RUN chmod +x ./autogen.sh
RUN ./autogen.sh
RUN ./configure 
RUN make 
RUN make install

RUN mkdir /scripts

COPY ./scripts /scripts

CMD ["chmod", "+x", "/scripts/entrypoint.sh"]
