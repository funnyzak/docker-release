#!/bin/bash
# Author: Leon<silenceace at gmail.com>

export PATH=$PATH:/usr/local/bin

# log message
# usage: log "message" "level" "push_message"
# example: log "hello world" "info" "true"
log() {
  log_level="info"
  push_message="false"
  if [ -n "$2" ]; then
    log_level=$2
  fi
  if [ -n "$3" ]; then
    push_message=$3
  fi

  echo -e "[gitjob] $(date '+%Y-%m-%d %H:%M:%S') [${log_level}] $1 "

  # log_level to upcase
  log_level_upcase=$(echo $log_level | tr '[a-z]' '[A-Z]')
  if [ -n "$PUSHOO_PUSH_PLATFORMS" -a -n "$PUSHOO_PUSH_TOKENS" ] && [ "$push_message" = "true" ]; then
    pushoo -P "${PUSHOO_PUSH_PLATFORMS}" -K "${PUSHOO_PUSH_TOKENS}" -O "${PUSHOO_PUSH_OPTIONS}" -C "# Git Job Message
$1
>From $SERVER_NAME (${log_level})" -T "$SERVER_NAME" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
      echo -e "$(date '+%Y-%m-%d %H:%M:%S') [error] push message failed."
    else 
      echo -e "$(date '+%Y-%m-%d %H:%M:%S') [info] push message success."
    fi
  fi
}

# $1 command
# $2 name
run_command() {
  if [ -z "$1" ]; then
    log "$2 command is empty. Skiped." "warn"
    return
  fi

  eval "$1" 1>/app/tmp/tmp_output_log 2>/app/tmp/tmp_error_log
  if [ $? -ne 0 ]; then
    log "Execute $1 command: $1 failed. Please check your command. Error log: $(cat /app/tmp/tmp_error_log)" "error" "true"
    exit 1
  else
    log "Execute $2 command: $1 success. Output log: $(cat /app/tmp/tmp_output_log)"
  fi
}

# $1 folder path $2 shell type
run_folder_scripts() {
  if [ -n "$(ls -A $1/ -A | grep '.sh' 2>/dev/null)" ]; then
    for file in $1/*; do
      if [ ! -d "$file" ]; then
        $file 1>/app/tmp/tmp_output_log 2>/app/tmp/tmp_error_log
        if [ $? -ne 0 ]; then
          log "Run $2 shell file: $file failed. Please check your $2 shell. Error log: $(cat /app/tmp/tmp_error_log)" "error" "true"
        else
          log "Run $2 shell file: $file success. Output log: $(cat /app/tmp/tmp_output_log)"
        fi
      fi
    done
    log "Run $2 shell files done."
  else 
    log "No $2 shell file found. Skiped."
  fi
}

print_environment() {
  log "Environment: \nGit name: ${GIT_USER_NAME}\nGit email: ${GIT_USER_EMAIL}\nGit Repo: ${GIT_REPO_URL}\nGit Branch: ${GIT_BRANCH}\nCode Dir: ${CODE_DIR}\nTarget Dir: ${TARGET_DIR}\nHook Dir: ${HOOK_DIR}\nHook log dir: ${HOOK_LOG_DIR}\nHook Token: ${HOOK_TOKEN}\nUse Hook: ${USE_HOOK}\nStartup Command: ${STARTUP_COMMANDS}\nBefore Pull Command: ${BEFORE_PULL_COMMAND}\nAfter Pull Command: ${AFTER_PULL_COMMAND}\nServer name: ${SERVER_NAME}\nPushoo push platforms: ${PUSHOO_PUSH_PLATFORMS}\nPushoo push tokens: ${PUSHOO_PUSH_TOKENS}"
}

execute_error_and_exit() {
  if [ $? -ne 0 ]; then
    exit 1
  fi
}

# checks if branch has something pending
parse_git_dirty() {
  git diff --quiet --ignore-submodules HEAD 2>/dev/null
    [ $? -eq 1 ] && echo "*"
}

# gets the current git branch
parse_git_branch() {
  git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(parse_git_dirty)/"
}

# get last commit hash prepended with @ (i.e. @8a323d0)
parse_git_hash() {
  git rev-parse --short HEAD 2>/dev/null | sed "s/\(.*\)/@\1/"
}

# get last commit message
parse_git_message() {
  git show --pretty=format:%s -s HEAD 2>/dev/null
}

prase_git_commitid() {
  git rev-parse HEAD 2>/dev/null
}

parse_git_author() {
  git show --pretty=format:%an -s HEAD 2>/dev/null
}

parse_git_date() {
  git show --pretty=format:%ad -s HEAD 2>/dev/null
}