FROM debian:latest
ARG version
RUN apt update && apt upgrade -y && apt install -y curl gpg ca-certificates tar dirmngr
RUN curl -o dogecoin.tar.gz -Lk https://github.com/dogecoin/dogecoin/releases/download/v1.14.6/dogecoin-1.14.6-x86_64-linux-gnu.tar.gz
RUN tar -xvf dogecoin.tar.gz
RUN rm dogecoin.tar.gz
RUN install -m 0755 -o root -g root -t /usr/local/bin dogecoin-${version}/bin/*
EXPOSE 22556
CMD ["dogecoind", "-printtoconsole", "-txindex", "-rpcbind=0.0.0.0"]
LABEL name="dogecoin" version="1.14.6" description="dogecoin"
LABEL maintainer="Sandshrew Inc <inquiries@sandshrew.io>"
