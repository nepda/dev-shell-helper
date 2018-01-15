#!/usr/bin/env bash

serviceName=$1

if [ "${serviceName}" = "" ] || [ "${serviceName}" = "--help" ]
then
    echo "Usage $0 [service-name.service]"
    echo ""
    echo "Stops the systemd user services and waits for real end of processes"
    echo "Stops also all services which ConsistsOf this one (recursively)"
    exit 1
fi

ExecMainPID=$(systemctl --user show ${serviceName} -p ExecMainPID | cut -d '=' -f 2)
list=$(systemctl --user show ${serviceName} -p ConsistsOf | cut -d '=' -f 2)

# recursive stopping ConsistsOf services
if [ "$list" != "" ]
then
    for s in ${list}
    do
        bash $0 ${s}
    done
fi

echo -n "PID ${serviceName}: ${ExecMainPID}"
systemctl --user stop ${serviceName}
echo -n ", waiting to be stopped"
if [ "${ExecMainPID}" -gt 0 ]
then
    while kill -0 ${ExecMainPID} 2> /dev/null;
    do
        echo -n "."
        sleep 1
    done
fi
echo ""
