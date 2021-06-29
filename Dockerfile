FROM alpine/git:v2.30.2

## install gh cli
RUN mkdir /ghcli && wget https://github.com/cli/cli/releases/download/v1.11.0/gh_1.11.0_linux_386.tar.gz -O ghcli.tar.gz
RUN tar --strip-components=1 -xf ghcli.tar.gz

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
