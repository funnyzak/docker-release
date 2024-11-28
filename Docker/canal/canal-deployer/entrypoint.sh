#!/bin/bash
bash /opt/canal/${CANAL_COMPONENT_NAME}/bin/startup.sh
sleep 3
tail -f /opt/canal/${CANAL_COMPONENT_NAME}/logs/deployer/deployer.log