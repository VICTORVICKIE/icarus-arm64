echo ====================
echo ==  ICARUS SERVER ==
echo ====================

echo Server Name : $SERVERNAME
echo Game Port   : $PORT
echo Query Port  : $QUERYPORT
echo Steam UID   : $STEAM_USERID
echo Steam GID   : $STEAM_GROUPID
echo Branch      : $BRANCH

echo ====================
echo Setting User ID...

groupmod -g "${STEAM_GROUPID}" steam \
  && usermod -u "${STEAM_USERID}" -g "${STEAM_GROUPID}" steam

export WINEPREFIX=/home/steam/icarus
export WINEARCH=win64
export WINEPATH=/game/icarus

echo Initializing Wine...
sudo -u steam wineboot --init > /dev/null 2>&1

echo Changing wine folder permissions...
chown -R "${STEAM_USERID}":"${STEAM_GROUPID}" /home/steam

echo ==============================================================
echo Updating/downloading game through steam
echo ==============================================================
sudo -u steam /home/steam/steamcmd/steamcmd.sh \
    +@sSteamCmdForcePlatformType windows \
    +force_install_dir /game/icarus \
    +login anonymous \
    +app_update 2089300 -beta "${BRANCH}" validate \
    +quit

echo ==============================================================
echo Setting Steam Async Timeout value in Engine.ini to $STEAM_ASYNC_TIMEOUT
echo ==============================================================
configPath='/home/steam/.wine/drive_c/icarus/Saved/Config/WindowsServer'
engineIni="${configPath}/Engine.ini"
if [[ ! -e ${engineIni} ]]; then
  mkdir -p ${configPath}
  touch ${engineIni}
fi
chown -R "${STEAM_USERID}":"${STEAM_GROUPID}" ${engineIni}

if ! grep -Fq "[OnlineSubsystemSteam]" ${engineIni}
then
    echo '[OnlineSubsystemSteam]' >> ${engineIni}
    echo 'AsyncTaskTimeout=' >> ${engineIni}
fi

sedCommand="/AsyncTaskTimeout=/c\AsyncTaskTimeout=${STEAM_ASYNC_TIMEOUT}"
sed -i ${sedCommand} ${engineIni}

echo ==============================================================
echo Setting Server settings in GameUserSettings.ini
echo ==============================================================

echo Session Name       : $SERVERNAME
echo Max Players        : $MAX_PLAYERS
echo Shutdown If Not Joined For : $SHUTDOWN_NOT_JOINED_FOR
echo Shutdown If Empty For      : $SHUTDOWN_EMPTY_FOR
echo Allow Non Admins To Launch Prospects : $ALLOW_NON_ADMINS_LAUNCH
echo Allow Non Admins To Delete Prospects : $ALLOW_NON_ADMINS_DELETE
echo Load Prospect      : $LOAD_PROSPECT
echo Create Prospect    : $CREATE_PROSPECT
echo Resume Prospect    : $RESUME_PROSPECT

serverSettingsIni="${configPath}/ServerSettings.ini"
if [[ ! -e ${serverSettingsIni} ]]; then
  touch ${serverSettingsIni}
fi
chown -R "${STEAM_USERID}":"${STEAM_GROUPID}" ${serverSettingsIni}

if ! grep -Fq "[/Script/Icarus.DedicatedServerSettings]" ${serverSettingsIni}
then
    echo '[/Script/Icarus.DedicatedServerSettings]' >> ${serverSettingsIni}
    echo "SessionName=${SERVERNAME}" >> ${serverSettingsIni}
    echo "JoinPassword=${JOIN_PASSWORD}" >> ${serverSettingsIni}
    echo "MaxPlayers=${MAX_PLAYERS}" >> ${serverSettingsIni}
    echo "AdminPassword=${ADMIN_PASSWORD}" >> ${serverSettingsIni}
    echo "ShutdownIfNotJoinedFor=${SHUTDOWN_NOT_JOINED_FOR}" >> ${serverSettingsIni}
    echo "ShutdownIfEmptyFor=${SHUTDOWN_EMPTY_FOR}" >> ${serverSettingsIni}
    echo "AllowNonAdminsToLaunchProspects=${ALLOW_NON_ADMINS_LAUNCH}" >> ${serverSettingsIni}
    echo "AllowNonAdminsToDeleteProspects=${ALLOW_NON_ADMINS_DELETE}" >> ${serverSettingsIni}
    echo "LoadProspect=${LOAD_PROSPECT}" >> ${serverSettingsIni}
    echo "CreateProspect=${CREATE_PROSPECT}" >> ${serverSettingsIni}
    echo "ResumeProspect=${RESUME_PROSPECT}" >> ${serverSettingsIni}
fi

sed -i "/SessionName=/c\SessionName=${SERVERNAME}" ${serverSettingsIni}
sed -i "/JoinPassword=/c\JoinPassword=${JOIN_PASSWORD}" ${serverSettingsIni}
sed -i "/MaxPlayers=/c\MaxPlayers=${MAX_PLAYERS}" ${serverSettingsIni}
sed -i "/AdminPassword=/c\AdminPassword=${ADMIN_PASSWORD}" ${serverSettingsIni}
sed -i "/ShutdownIfNotJoinedFor=/c\ShutdownIfNotJoinedFor=${SHUTDOWN_NOT_JOINED_FOR}" ${serverSettingsIni}
sed -i "/ShutdownIfEmptyFor=/c\ShutdownIfEmptyFor=${SHUTDOWN_EMPTY_FOR}" ${serverSettingsIni}
sed -i "/AllowNonAdminsToLaunchProspects=/c\AllowNonAdminsToLaunchProspects=${ALLOW_NON_ADMINS_LAUNCH}" ${serverSettingsIni}
sed -i "/AllowNonAdminsToDeleteProspects=/c\AllowNonAdminsToDeleteProspects=${ALLOW_NON_ADMINS_DELETE}" ${serverSettingsIni}
sed -i "/LoadProspect=/c\LoadProspect=${LOAD_PROSPECT}" ${serverSettingsIni}
sed -i "/CreateProspect=/c\CreateProspect=${CREATE_PROSPECT}" ${serverSettingsIni}
sed -i "/ResumeProspect=/c\ResumeProspect=${RESUME_PROSPECT}" ${serverSettingsIni}

echo ==============================================================
echo Changing config folder permissions...
chown -R "${STEAM_USERID}":"${STEAM_GROUPID}" home/steam/.wine/drive_c/icarus

echo ==============================================================
echo Starting Server - Buckle up prospectors!
echo ==============================================================
exec sudo -u steam wine /game/icarus/Icarus/Binaries/Win64/IcarusServer-Win64-Shipping.exe \
  -Log \
  -UserDir='C:\icarus' \
  -SteamServerName="${SERVERNAME}" \
  -PORT="${PORT}" \
  -QueryPort="${QUERYPORT}"
