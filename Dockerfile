FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CMAKE_PREFIX_PATH=/usr/lib/x86_64-linux-gnu/cmake/Qt5

# Default Environment Vars
ENV SERVERNAME="Icarus Server"
ENV PORT=17777
ENV QUERYPORT=27015

# Server Settings
ENV JOIN_PASSWORD=""
ENV MAX_PLAYERS=8
ENV ADMIN_PASSWORD="admin"
ENV SHUTDOWN_NOT_JOINED_FOR=-1
ENV SHUTDOWN_EMPTY_FOR=-1
ENV ALLOW_NON_ADMINS_LAUNCH="True"
ENV ALLOW_NON_ADMINS_DELETE="False"
ENV LOAD_PROSPECT=""
ENV CREATE_PROSPECT=""
ENV RESUME_PROSPECT="True"

# Default User/Group ID
ENV STEAM_USERID=1000
ENV STEAM_GROUPID=1000

# Engine.ini Async Timeout
ENV STEAM_ASYNC_TIMEOUT=60

# SteamCMD Environment Vars
ENV BRANCH="public"

RUN apt-get update && \
    apt-get install -y \
    git \
    cmake \
    ninja-build \
    pkg-config \
    ccache \
    clang \
    llvm \
    lld \
    binfmt-support \
    libsdl2-dev \
    libepoxy-dev \
    libssl-dev \
    python-setuptools \
    g++-x86-64-linux-gnu \
    nasm \
    python3-clang \
    libstdc++-10-dev-i386-cross \
    libstdc++-10-dev-amd64-cross \
    libstdc++-10-dev-arm64-cross \
    squashfs-tools \
    squashfuse \
    libc-bin \
    expect \
    curl \
    sudo \
    fuse \
    qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools \
    qtdeclarative5-dev qml-module-qtquick2 \
    binfmt-support \
    ca-certificates \
    wget \
    gnupg2 \
    software-properties-common \
    wine \
    wine64

# Create various folders
RUN mkdir -p /root/icarus/drive_c/icarus \ 
             /game/icarus \
             /home/steam/Steam

# Copy run script
COPY runicarus.sh /
RUN chmod +x /runicarus.sh

# Create Steam user
RUN groupadd -g "${STEAM_GROUPID}" steam \
  && useradd --create-home --no-log-init -u "${STEAM_USERID}" -g "${STEAM_GROUPID}" steam
RUN chown -R "${STEAM_USERID}":"${STEAM_GROUPID}" /home/steam
RUN chown -R "${STEAM_USERID}":"${STEAM_GROUPID}" /game/icarus

RUN useradd -m -s /bin/bash fex && \
    usermod -aG sudo fex && \
    echo "fex ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/fex

USER fex

WORKDIR /home/fex

RUN git clone --recurse-submodules https://github.com/FEX-Emu/FEX.git && \
    cd FEX && \
    mkdir Build && \
    cd Build && \
    CC=clang CXX=clang++ cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DUSE_LINKER=lld -DENABLE_LTO=True -DBUILD_TESTS=False -DENABLE_ASSERTIONS=False -G Ninja .. && \
    ninja

WORKDIR /home/fex/FEX/Build

RUN sudo ninja install && \
    sudo update-binfmts --enable


USER root

RUN echo 'root:steamcmd' | chpasswd

USER steam

RUN mkdir -p /home/steam/.fex-emu/RootFS/
RUN chown -R "${STEAM_USERID}":"${STEAM_GROUPID}" /home/steam/.fex-emu
RUN chmod -R 755 /home/steam/.fex-emu

WORKDIR /home/steam/.fex-emu/RootFS/

RUN wget -O Ubuntu_22_04.tar.gz https://www.dropbox.com/scl/fi/16mhn3jrwvzapdw50gt20/Ubuntu_22_04.tar.gz?rlkey=4m256iahwtcijkpzcv8abn7nf && \
    tar xzf Ubuntu_22_04.tar.gz && \
    rm ./Ubuntu_22_04.tar.gz

WORKDIR /home/steam/.fex-emu

RUN echo '{"Config":{"RootFS":"Ubuntu_22_04"}}' > ./Config.json

WORKDIR /home/steam/Steam

RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

ENTRYPOINT FEXBash /runicarus.sh
