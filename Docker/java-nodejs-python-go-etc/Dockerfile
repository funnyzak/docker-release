FROM debian:stable-20250929-slim as base

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

ARG GO_VERSION=1.23.2

ENV TZ=Asia/Shanghai
ENV LANG=C.UTF-8


LABEL org.label-schema.name="java-nodejs-python-go-etc" \
    org.label-schema.description="java-nodejs-python-go-etc" \
    org.label-schema.version="${VERSION}" \
    org.label-schema.vcs-ref="${VCS_REF}" \
    org.label-schema.build-date="${BUILD_DATE}" \
    org.label-schema.vendor="Leon<silenceace@gmail.com>" \
    org.label-schema.url="https://github.com/funnyzak/docker-release"

COPY repo/sources.list /etc/apt/sources.list

# Install need modules
RUN apt-get update && \
    # gyp compilation
    apt-get install -y g++ gcc make && \
    # base modules
    apt-get install -y gnupg2 openssl tree bash git vim curl wget && \
    # clean
    rm -rf /var/lib/apt/lists/*

# Install Package
RUN apt-get update && \
    apt-get -y upgrade && \
    # Install modules
    apt-get install -y rsync rclone && \
    apt-get install -y zip unzip gzip tar tzdata && \
    # ms fonts
    apt-get install -y ttf-mscorefonts-installer && \
    # cert
    apt-get install -y ca-certificates && \
    # command ps
    apt-get install -y procps && \
    # python
    apt-get install -y python3 python3-venv python3-pip && \
    apt-get install -y apprise && \
    # nodejs and npm
    apt-get install -y nodejs npm && \
    # clean
    apt-get clean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*

# yarn and pnpm
RUN npm install -g yarn pnpm pushoo-cli

# GO
ENV GO_BINARY_TAR_NAME=go${GO_VERSION}.linux-amd64
ENV GO_BINARY_TAR_DOWNLOAD_LINK=https://dl.google.com/go/${GO_BINARY_TAR_NAME}.tar.gz

RUN wget ${GO_BINARY_TAR_DOWNLOAD_LINK} -O ${GO_BINARY_TAR_NAME}.tar.gz && \
    tar -C /usr/local -xzf ${GO_BINARY_TAR_NAME}.tar.gz && \
    rm ${GO_BINARY_TAR_NAME}.tar.gz && \
    mkdir -p /go/src /go/bin && chmod -R 755 /go
ENV PATH=$PATH:/usr/local/go/bin
ENV GOPATH=/go

# Install Go Webhook
RUN curl -Lo /tmp/webhook-linux-amd64.tar.gz https://github.com/adnanh/webhook/releases/download/2.8.2/webhook-linux-amd64.tar.gz && \
    tar -C /tmp -xzf /tmp/webhook-linux-amd64.tar.gz && \
    mv /tmp/webhook-linux-amd64/webhook /opt/webhook && \
    chmod 755 /opt/webhook && \
    ln -s /opt/webhook /usr/local/bin && \
    rm -f /tmp/webhook-linux-amd64.tar.gz

# ossutil64
RUN curl -Lo /tmp/ossutil.zip https://gosspublic.alicdn.com/ossutil/v2-beta/2.0.3-beta.09261200/ossutil-2.0.3-beta.09261200-linux-amd64.zip && \
    unzip /tmp/ossutil.zip -d /tmp && \
    mv /tmp/ossutil-2.0.3-beta.09261200-linux-amd64/ossutil /opt/ossutil && \
    chmod 755 /opt/ossutil && \
    ln -s /opt/ossutil /usr/local/bin && \
    rm -f /tmp/ossutil.zip

# Minio Client
RUN curl https://dl.min.io/client/mc/release/linux-amd64/mc --create-dirs -o /opt/minio-binaries/mc && \
    chmod +x /opt/minio-binaries/mc && \
    ln -s /opt/minio-binaries/mc /usr/local/bin

# Java 8 配置
ENV JAVA_VERSION=jdk8u432-b06
ENV JAVA_PACKAGE_FILENAME=OpenJDK8U-jdk_x64_linux_hotspot_8u432b06.tar.gz
ENV JAVA_DOWNLOAD_LINK=https://github.com/adoptium/temurin8-binaries/releases/download/${JAVA_VERSION}/${JAVA_PACKAGE_FILENAME}

# 下载并安装 Java 8
RUN wget --no-cookies -O /tmp/${JAVA_PACKAGE_FILENAME} ${JAVA_DOWNLOAD_LINK} && \
    mkdir -p /opt/java && \
    tar -zxf /tmp/${JAVA_PACKAGE_FILENAME} -C /opt/java/ && \
    rm -f /tmp/${JAVA_PACKAGE_FILENAME}

# Java 环境变量
ENV JAVA_HOME=/opt/java/${JAVA_VERSION}
ENV JRE_HOME=${JAVA_HOME}/jre
ENV CLASSPATH=.:${JAVA_HOME}/lib/dt.jar:${JAVA_HOME}/lib/tools.jar:${JRE_HOME}/lib
ENV PATH=${JAVA_HOME}/bin:$PATH


# maven
ENV MAVEN_VERSION=3.9.9
ENV MAVEN_HOME=/opt/maven
RUN wget --no-verbose -O /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    http://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    tar xzf /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt/ && \
    ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven && \
    ln -s /opt/maven/bin/mvn /usr/local/bin && \
    rm -f /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz

WORKDIR /app

# 保持容器运行
CMD ["tail", "-f", "/dev/null"]