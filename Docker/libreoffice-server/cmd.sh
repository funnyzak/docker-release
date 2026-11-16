#!/bin/bash

cd /app/nodeapp
git pull
npm ci --prefix /app/nodeapp

npm start --prefix /app/nodeapp