FROM ghcr.io/supportpal/github-gh-cli:latest

## install gh cli
# RUN mkdir /ghcli && wget -c https://github.com/cli/cli/releases/download/v1.11.0/gh_1.11.0_linux_386.tar.gz -O -| tar --strip-components=1 -C /ghcli -xz && ln -s /ghcli/bin/gh /usr/local/bin/

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
