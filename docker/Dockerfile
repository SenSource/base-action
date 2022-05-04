## Based on timbru31/node-alpine-git:16
## https://github.com/timbru31/docker-node-alpine-git/blob/master/16/Dockerfile

FROM node:gallium-alpine3.14

## install git & openssh
RUN apk update && apk upgrade && \
  echo @edge http://nl.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories && \
  echo @edge http://nl.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories && \
  && apk add --no-cache \
  git \
  openssh \
  ## install Chrome for headless browser for testing client apps
  chromium@edge nss@edge \
  ## install GitHub CLI
  && mkdir /ghcli \
  && wget -c https://github.com/cli/cli/releases/download/v1.11.0/gh_1.11.0_linux_386.tar.gz -O -| tar --strip-components=1 -C /ghcli -xz \
  && ln -s /ghcli/bin/gh /usr/local/bin/

ENV CHROME_BIN /usr/bin/chromium-browser
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true