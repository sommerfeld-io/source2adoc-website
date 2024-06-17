##
# This Dockerfile is designed to streamline the build process of the
# link:https://source2adoc.sommerfeld.io[source2adoc.sommerfeld.io] website. The purpose of this
# Dockerfile is to generate the documentation sites using link:https://www.antora.org[Antora].
#
# == How to use
# Use `docker run --rm -p "7880:7880" sommerfeldio/source2adoc-website:rc` to run the most
# recent release candidate from DockerHub.
##


##
# Build the ui bundle and the antora pages.
##
FROM node:22.3.0-alpine3.19 AS build
LABEL maintainer="sebastian@sommerfeld.io"

RUN yarn global add @asciidoctor/core@~3.0.2 \
    && yarn global add asciidoctor-kroki@~0.18.1 \
    && yarn global add @antora/cli@3.1.7 \
    && yarn global add @antora/site-generator@3.1.7 \
    && yarn global add @antora/lunr-extension@~1.0.0-alpha.8 \
    && yarn global add gulp-cli@3.0.0

COPY components/antora-ui-default-master /antora-ui
WORKDIR /antora-ui
RUN yarn install && gulp bundle

COPY config /antora
WORKDIR /antora
RUN antora playbooks/public.yml --stacktrace --clean --fetch

# sleep for a moment ... otherwise the search-index.js is not built correctly
#RUN sleep 5


##
# Expose the documentation site using httpd.
#
# To avoid running the httpd and thes image as `root`, the permissions of `/usr/local/apache2/logs`
# are changed to allow `www-data` to write logs. Additionally the default http port is changed to
# `7880`, so keep that in mind when mapping ports in a `docker run ...` command. This way the image
# can be used without root permissions because the httpd server inside the container is started
# with the already existing user `www-data`.
#
# The webserver exposes his status information through http://localhost:7880/server-status.
##
FROM httpd:2.4.59-alpine3.19 AS run
LABEL maintainer="sebastian@sommerfeld.io"

ARG USER=www-data
RUN chown -hR "$USER:$USER" /usr/local/apache2 \
    && chmod g-w /usr/local/apache2/conf/httpd.conf \
    && chmod g-r /etc/shadow \
    && rm /usr/local/apache2/htdocs/index.html

COPY config/httpd.conf /usr/local/apache2/conf/httpd.conf
COPY --from=build /tmp/antora/source2adoc-website/public /usr/local/apache2/htdocs

USER "$USER"
