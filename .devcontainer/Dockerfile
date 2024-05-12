# @file Dockerfile
# @brief A devcontainer image tailored specifically for the project.
#
# @description This Dockerfile represents the development environment container tailored
# specifically for the project. It serves as the foundation for encapsulating all necessary
# dependencies within the image, ensuring a consistent and reproducible environment across
# various workstations.
#
# === Prerequisites
#
# Having Visual Studio Code (VSCode) and the Dev Container plugin installed are
# essential prerequisites for this development environment. This devcontainer has
# been tested with Docker version 24.0.2 on top of Ubuntu 22.10.

FROM mcr.microsoft.com/devcontainers/javascript-node:22-bullseye
LABEL maintainer="sebastian@sommerfeld.io"

ARG USER=node

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN chsh --shell /bin/bash "$USER" \
    && echo "alias ls='ls -a'" >> "/home/$USER/.bashrc" \
    && echo "alias ll='ls -alF'" >> "/home/$USER/.bashrc" \
    && apt-get update \
    && apt-get install -y --no-install-recommends python3-pip=20.3.4-4+deb11u1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir pre-commit==3.3.3 \
    && npm install --location=global gulp-cli@2.3.0 \
    && npm install --location=global @antora/cli@3.1 \
    && npm install --location=global @antora/site-generator@3.1
