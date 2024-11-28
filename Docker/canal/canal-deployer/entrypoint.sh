#!/bin/bash
bash /opt/canal/canal-${CANAL_NAME}/bin/startup.sh
sleep 3
tail -f /opt/canal/canal-${CANAL_NAME}/logs/${CANAL_NAME}/${CANAL_NAME}.log