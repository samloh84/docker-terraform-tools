FROM ubuntu:latest AS final_build

ARG GO_VERSION="1.16.6"
ARG GO_ARCHIVE_SHA256="be333ef18b3016e9d7cb7b1ff1fdb0cac800ca0be4cf2290fe613b3d069dfe0d"
ARG OPA_VERSION="0.30.2"
ARG CONFTEST_VERSION="0.25.0"


RUN \
set -x && \
export DEBIAN_FRONTEND="noninteractive" && \
export TZ="Asia/Singapore" && \
apt-get update && \
apt-get install -y \
curl \
jq \
git \
nano \
ruby \
ruby-dev \
python3 \
python3-pip \
software-properties-common && \
rm -rf /var/lib/apt/lists/*

RUN \
set -x && \
GO_ARCHIVE_FILENAME="go${GO_VERSION}.linux-amd64.tar.gz" && \
GO_ARCHIVE_URL="https://golang.org/dl/${GO_ARCHIVE_FILENAME}" && \
GO_TEMP_DIR="/tmp/go/${GO_VERSION}" && \
GO_ARCHIVE="${GO_TEMP_DIR}/${GO_ARCHIVE_FILENAME}" && \
GO_INSTALL_DIR="/opt/go/${GO_VERSION}" && \
mkdir -p "${GO_TEMP_DIR}" "${GO_INSTALL_DIR}" && \
curl -sSLj -o "${GO_ARCHIVE}" "${GO_ARCHIVE_URL}" && \
cd ${GO_TEMP_DIR} && \
echo "${GO_ARCHIVE_SHA256} ${GO_ARCHIVE_FILENAME}" | sha256sum --check --status && \
tar -C "${GO_INSTALL_DIR}" --strip-components=1 -xzf "${GO_ARCHIVE}" && \
rm -rf "${GO_TEMP_DIR}"

ENV PATH="${PATH}:/opt/go/${GO_VERSION}/bin"


RUN \
set -x && \
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
apt-get update && \
apt-get install -y terraform && \
rm -rf /var/lib/apt/lists/*

RUN \
set -x && \
OPA_BINARY_FILENAME="opa_linux_amd64" && \
OPA_BINARY_URL="https://github.com/open-policy-agent/opa/releases/download/v${OPA_VERSION}/${OPA_BINARY_FILENAME}" && \
OPA_INSTALL_DIR="/opt/opa/${OPA_VERSION}" && \
OPA_BINARY="${OPA_INSTALL_DIR}/bin/${OPA_BINARY_FILENAME}" && \
mkdir -p "${OPA_INSTALL_DIR}/bin" && \
curl -sSLj -o "${OPA_BINARY}" "${OPA_BINARY_URL}" && \
chmod +x "${OPA_BINARY}" && \
update-alternatives --install "/usr/bin/opa" "opa" "${OPA_BINARY}" 1

RUN \
set -x && \
AWS_CLI_ARCHIVE_FILENAME="awscli-exe-linux-x86_64.zip" && \
AWS_CLI_ARCHIVE_URL="https://awscli.amazonaws.com/${AWS_CLI_ARCHIVE_FILENAME}" && \
AWS_CLI_TEMP_DIR="/tmp/aws" && \
AWS_CLI_ARCHIVE="${AWS_CLI_TEMP_DIR}/${AWS_CLI_ARCHIVE_FILENAME}" && \
AWS_CLI_INSTALL_DIR="/opt/aws" && \
mkdir -p "${AWS_CLI_TEMP_DIR}" && \
curl -sSLj -o "${AWS_CLI_ARCHIVE}" "${AWS_CLI_ARCHIVE_URL}" && \
unzip -d "${AWS_CLI_TEMP_DIR}" "${AWS_CLI_ARCHIVE}" && \
cd "${AWS_CLI_TEMP_DIR}/aws" && \
./install && \
rm -rf "${AWS_CLI_TEMP_DIR}"


RUN \
set -x && \
CONFTEST_PACKAGE_FILENAME="conftest_${CONFTEST_VERSION}_linux_amd64.deb" && \
CONFTEST_PACKAGE_URL="https://github.com/open-policy-agent/conftest/releases/download/v${CONFTEST_VERSION}/${CONFTEST_PACKAGE_FILENAME}" && \
CONFTEST_TEMP_DIR="/tmp/conftest/${CONFTEST_VERSION}" && \
CONFTEST_PACKAGE="${CONFTEST_TEMP_DIR}/${CONFTEST_PACKAGE_FILENAME}" && \
mkdir -p "${CONFTEST_TEMP_DIR}" && \
curl -sSLj -o "${CONFTEST_PACKAGE}" "${CONFTEST_PACKAGE_URL}" && \
dpkg -i "${CONFTEST_PACKAGE}"

RUN \
set -x && \
pip3 install checkov

