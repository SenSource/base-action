## Based on timbru31/node-alpine-git:16
## https://github.com/timbru31/docker-node-alpine-git/blob/master/16/Dockerfile

FROM node:gallium-alpine3.14

## install git & openssh
RUN apk -U upgrade \
  && apk add --no-cache \
  git \
  openssh \
  ## install chromium for headless browser for testing client apps
  chromium \
  && export CHROME_BIN='/usr/bin/chromium' \
  ## install GitHub CLI
  && mkdir /ghcli \
  && wget -c https://github.com/cli/cli/releases/download/v1.11.0/gh_1.11.0_linux_386.tar.gz -O -| tar --strip-components=1 -C /ghcli -xz \
  && ln -s /ghcli/bin/gh /usr/local/bin/
