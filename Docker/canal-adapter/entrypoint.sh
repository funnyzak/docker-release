#!/bin/bash
bash /opt/canal/${CANAL_COMPONENT_NAME}/bin/startup.sh
sleep 3
tail -f logs/canal/canal.log