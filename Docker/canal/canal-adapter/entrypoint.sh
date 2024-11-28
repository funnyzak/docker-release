#!/bin/bash
bash /opt/canal/${CANAL_DIR_NAME}/bin/startup.sh
sleep 3
tail -f /opt/canal/${CANAL_DIR_NAME}/logs/adapter/adapter.log