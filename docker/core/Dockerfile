FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
# This Dockerfile adds a non-root 'vscode' user with sudo access. However, for Linux,
# this user's GID/UID must match your local user UID/GID to avoid permission issues
# with bind mounts. Update USER_UID / USER_GID if yours is not 1000. See
# https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
# setup apt / certificates
RUN apt-get update \
    # Verify process tools, lsb-release (common in install instructions for CLIs) installed
    && apt-get -y install iproute2 procps lsb-release \
    #
    # Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # [Optional] Add sudo support for the non-root user
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Add test tool chain
# NOTE: newer version of the compilers are not
#    provided by stock distributions
#    and are provided by the /test toolchain
# RUN apt-get -y install software-properties-common \
#     && add-apt-repository ppa:ubuntu-toolchain-r/test \
#    && apt-get update

# Install common compilation tools
RUN apt-get -y install git build-essential pkg-config autoconf automake libtool bison flex libpq-dev parallel libunwind-dev

# Update compiler tools
RUN apt-get -y install libstdc++-7-dev clang-format-8 ccache

# gcc
RUN apt-get -y install cpp-7 gcc-7 g++-7
# clang
RUN apt-get -y install clang-8 llvm-8

# clang by default
ENV CC=clang-8
ENV CXX=clang++-8

# Install postgresql to enable tests under make check
RUN apt-get -y install postgresql

# Set up locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /vhosts

RUN git clone -b main https://github.com/SudaPort/core.git core

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
# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=
CMD ["chmod", "+x", "/scripts/entrypoint.sh"]
