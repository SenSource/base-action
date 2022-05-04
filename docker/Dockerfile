## Based on timbru31/node-alpine-git:16
## https://github.com/timbru31/docker-node-alpine-git/blob/master/16/Dockerfile

FROM node:gallium-alpine3.14

RUN apk update && apk upgrade && \
  apk add --no-cache \
    ## install git & openssh
    git openssh \
    ## install Chrome for headless browser for testing client apps
    chromium nss && \
  ## install GitHub CLI
  mkdir /ghcli && \
  wget -c https://github.com/cli/cli/releases/download/v1.11.0/gh_1.11.0_linux_386.tar.gz -O -| tar --strip-components=1 -C /ghcli -xz && \
  ln -s /ghcli/bin/gh /usr/local/bin/

ENV CHROME_BIN /usr/bin/chromium-browser
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true