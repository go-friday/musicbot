# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.137.0/containers/go/.devcontainer/base.Dockerfile
ARG VARIANT="1"
FROM mcr.microsoft.com/vscode/devcontainers/go:0-${VARIANT}

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends unzip
RUN apt-get update && apt-get install gnupg2 -y

# [Optional] Uncomment the next line to use go get to install anything else you need
# RUN go get -x <your-dependency-or-tool>

ENV RELEASE_TAG=v11.36.0
COPY ./install.sh .
RUN ./install.sh /var/balena
ENV PATH="/var/balena/balena-cli:${PATH}"