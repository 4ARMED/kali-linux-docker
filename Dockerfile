FROM kalilinux/kali-linux-docker
ARG CLOUD_SDK_VERSION=236.0.0
ARG KUBELETMEIN_VERSION=0.6.1
ENV CLOUD_SDK_VERSION=$CLOUD_SDK_VERSION
ENV KUBELETMEIN_VERSION=$KUBELETMEIN_VERSION

RUN echo "deb http://http.kali.org/kali kali-rolling main contrib non-free" > /etc/apt/sources.list && \
    echo "deb-src http://http.kali.org/kali kali-rolling main contrib non-free" >> /etc/apt/sources.list
ENV DEBIAN_FRONTEND noninteractive
RUN set -x \
    && apt-get -yqq update \
    && apt-get -yqq dist-upgrade \
    && apt-get install -y curl \
        ncat \
        nmap \
        host \
        python \
        python-pip \
        gcc \
        python-dev \
        python-setuptools \
        apt-transport-https \
        openssh-client \
        git \
        gnupg \
        jq \
    && apt-get clean -yqq
RUN set -x && \
    pip install awscli crcmod && \
    mkdir /root/.aws && \
    echo '[default]\nregion = eu-west-1' > /root/.aws/config

RUN export CLOUD_SDK_REPO="cloud-sdk-stretch" && \
    echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update -yqq && apt-get install -y google-cloud-sdk=${CLOUD_SDK_VERSION}-0 $INSTALL_COMPONENTS && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image

RUN wget -O /usr/local/bin/kubeletmein https://github.com/4ARMED/kubeletmein/releases/download/v${KUBELETMEIN_VERSION}/kubeletmein_${KUBELETMEIN_VERSION}_linux_amd64 && \
    chmod +x /usr/local/bin/kubeletmein

CMD ["bash"]
