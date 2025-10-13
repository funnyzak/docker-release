FROM funnyzak/java-nodejs-python-go-etc:2.0.0

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

# Set the timezone and locale
ENV TZ Asia/Shanghai
ENV LC_ALL C.UTF-8
ENV LANG=C.UTF-8

ENV PUSHOO_PUSH_PLATFORMS=
ENV PUSHOO_PUSH_TOKENS=

ENV PUSH_MESSAGE_HEAD=
ENV PUSH_MESSAGE_FOOT=

ENV STARTUP_COMMANDS=
ENV BEFORE_PULL_COMMANDS=
ENV AFTER_PULL_COMMANDS=

ENV GIT_USER_NAME=funnyzak
ENV GIT_USER_EMAIL=
ENV GIT_REPO_URL=
ENV GIT_BRANCH=
ENV USE_HOOK=true
ENV HOOK_TOKEN=

ENV SERVER_NAME=gitjob

ENV TARGET_DIR /app/target
ENV CODE_DIR /app/code
ENV HOOK_DIR /app/hook
ENV HOOK_LOG_DIR /var/log/webhook

# Create operation folders`
RUN mkdir -p ${CODE_DIR} && mkdir -p ${TARGET_DIR} && mkdir -p ${HOOK_DIR} && mkdir -p ${HOOK_LOG_DIR} && mkdir -p /app/tmp

# Copy hook rule and hook script
COPY conf/hooks.json ${HOOK_DIR}/githooks.json

# Copy scripts to /app/scripts and set permissions
COPY scripts /app/scripts
RUN chmod +x -R /app/scripts

# Add any user custom scripts + set permissions
ADD conf/custom_scripts /custom_scripts
RUN chmod +x -R /custom_scripts

# Install nginx
RUN apt-get update && apt-get install -y nginx && apt-get clean && rm -rf /var/lib/apt/lists/*

# run nginx with root
RUN sed -i 's/^user [a-z0-9\-]\+/user root/' /etc/nginx/nginx.conf
# http proxy 9000 80 
COPY conf/nginx_default.conf /etc/nginx/conf.d/default.conf

# Remove default nginx config
RUN rm -rf /etc/nginx/sites-enabled/default && rm -rf /etc/nginx/sites-available/default

# Expose webhook and nginx port
EXPOSE 80 9000

WORKDIR ${CODE_DIR}

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=5 CMD [ "/app/scripts/healthcheck.sh" ]

ENTRYPOINT ["/bin/bash", "/app/scripts/entrypoint.sh"]