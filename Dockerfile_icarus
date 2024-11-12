FROM ubuntu:22.04

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

# Get prereq packages
RUN dpkg --add-architecture i386
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    ca-certificates \
    lib32gcc-s1 \
    sudo \
    curl \
    wget \
    gnupg2 \
    software-properties-common \
    wine \
    wine64

# Create various folders
RUN mkdir -p /root/icarus/drive_c/icarus \ 
             /game/icarus \
             /home/steam/steamcmd

# Copy run script
COPY runicarus.sh /
RUN chmod +x /runicarus.sh

# Create Steam user
RUN groupadd -g "${STEAM_GROUPID}" steam \
  && useradd --create-home --no-log-init -u "${STEAM_USERID}" -g "${STEAM_GROUPID}" steam
RUN chown -R "${STEAM_USERID}":"${STEAM_GROUPID}" /home/steam
RUN chown -R "${STEAM_USERID}":"${STEAM_GROUPID}" /game/icarus

# Install SteamCMD
RUN curl -s http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -v -C /home/steam/steamcmd -zx

ENTRYPOINT ["/bin/bash"]
CMD ["/runicarus.sh"]
