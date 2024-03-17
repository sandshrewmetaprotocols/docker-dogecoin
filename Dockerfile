FROM ubuntu:latest AS builder
ARG TARGETARCH

FROM builder AS builder_amd64
ENV ARCH=x86_64
FROM builder AS builder_arm64
ENV ARCH=aarch64
FROM builder AS builder_riscv64
ENV ARCH=riscv64

FROM builder_${TARGETARCH} AS build
RUN apt-get update
RUN apt-get install -y curl gpg ca-certificates tar dirmngr build-essential git autoconf libtool pkg-config libdb++-dev libboost-all-dev bsdmainutils openssl libssl-dev automake make
WORKDIR /opt
COPY dogecoin ./dogecoin
COPY bin ./bin
WORKDIR /opt/dogecoin
RUN rm -rf .git
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install

FROM debian:bookworm-slim
LABEL name="dogecoin" description="dogecoin"
LABEL maintainer="Sandshrew Inc <inquiries@sandshrew.io>"
ARG GROUP_ID=1000
ARG USER_ID=1000
RUN groupadd -g ${GROUP_ID} dogecoin \
    && useradd -u ${USER_ID} -g dogecoin -d /dogecoin dogecoin
ENV HOME /dogecoin
EXPOSE 22556
VOLUME ["/dogecoin/.dogecoin"]
WORKDIR /dogecoin
COPY --from=build /opt/ /opt/
RUN apt update \
    && apt install -y --no-install-recommends gosu libatomic1 libboost-all-dev libssl-dev libdb++-dev \
    && apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && ln -sv /opt/dogecoin/src/dogecoind /usr/local/bin/dogecoind \
    && ln -sv /opt/bin/* /usr/local/bin
ENTRYPOINT ["doge_oneshot"]
