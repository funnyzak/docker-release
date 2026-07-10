#!/bin/bash
source /app/scripts/utils.sh;

mkdir -p -m 600 /root/.ssh
mkdir -p -m 755 ${CODE_DIR}

log "Disable Strict Host checking for non interactive"
rm -f /root/.ssh/config
echo -e "Host *\n\tStrictHostKeyChecking no\n" > /root/.ssh/config

# check /root/.ssh/id_rsa exist
if [ ! -f "/root/.ssh/id_rsa" ]; then
  log "No ssh key found. Please set ssh key to /root/.ssh/id_rsa" "error"
  exit 1
fi

log "Set ssh key permission to 600"
chmod 600 /root/.ssh/id_rsa

if [ ! -z "$GIT_USER_NAME" ]; then
  git config --global user.name "$GIT_USER_NAME"
fi

if [ ! -z "$GIT_USER_EMAIL" ]; then
  git config --global user.email "$GIT_USER_EMAIL"
fi
log "Set git name: ${GIT_USER_NAME}, email: ${GIT_USER_EMAIL} done."

git config pull.rebase false
log "Set git pull.rebase false done."


if [ -z "$GIT_REPO_URL" ]; then
  log "GIT_REPO_URL is empty. Please set GIT_REPO_URL." "error"
  exit 1
fi

if [ -z "$(ls -A ${CODE_DIR})" ]; then
  log "CODE_DIR is empty. Will git clone to ${CODE_DIR}"

  if [ -z "$GIT_BRANCH" ]; then
    git clone --recursive $GIT_REPO_URL ${CODE_DIR}/ 2>/app/tmp/tmp_error_log
  else
    git clone  --recursive -b $GIT_BRANCH $GIT_REPO_URL ${CODE_DIR}/ 2>/app/tmp/tmp_error_log
  fi

  if [ $? -ne 0 ]; then
    log "git clone failed. Please check your GIT_REPO_URL and access permission. Error log: `cat /app/tmp/tmp_error_log`" "error" "true"
    exit 0
  fi

  GIT_BRANCH=$(cd ${CODE_DIR} && git rev-parse --abbrev-ref HEAD)
  export GIT_BRANCH

  git reset --hard origin/$GIT_BRANCH

  log "git clone from ${GIT_REPO_URL}, ${GIT_BRANCH} to ${CODE_DIR} done."
else 
  log "${CODE_DIR} is not empty. please remove the ${CODE_DIR} first. Skip git clone."
  log "set origin url to ${GIT_REPO_URL}"
  git remote set-url origin ${GIT_REPO_URL}
fi

chmod +x -R /custom_scripts
chmod +x -R ${HOOK_DIR}
log "Set /custom_scripts and ${HOOK_DIR} permission to 755 done."

run_command "$STARTUP_COMMANDS" "startup"
run_folder_scripts "/custom_scripts/on_startup" "on startup"

# Set hook rule
sed -i "s|{hook_token}|${HOOK_TOKEN}|g" ${HOOK_DIR}/githooks.json 
sed -i "s|{hook_branch}|${GIT_BRANCH}|g" ${HOOK_DIR}/githooks.json
sed -i "s|/app/code|${CODE_DIR}|g" ${HOOK_DIR}/githooks.json
log "Set hook config to ${HOOK_DIR}/githooks.json done. hook token: ${HOOK_TOKEN}, branch: ${GIT_BRANCH}, code dir: ${CODE_DIR}.\nConfig content:\n `cat ${HOOK_DIR}/githooks.json`"

source /app/scripts/hook.sh &

# nginx
# replace /etc/nginx/sites-available/default /app/target to ${TARGET_DIR}
sed -i "s|/app/target|${TARGET_DIR}|g" /etc/nginx/conf.d/default.conf
nginx -g "daemon off;" &
log "Start nginx done."

print_environment

if [ "$USE_HOOK" = "true" ]; then
  log "Set USE_HOOK. will run webhook."
  webhook -hooks ${HOOK_DIR}/githooks.json -verbose
else
  log "Not set USE_HOOK. will run hook.sh in 23h."
  while sleep 23h; do sh ${HOOK_DIR}/hook.sh; done
fi

exec "$@"