FROM golang:buster AS builder

RUN apt-get update && apt-get install -y gcc-aarch64-linux-gnu libc6-dev-arm64-cross

RUN INSTALL_PKGS=" \
      openssl \
      " && \
    apt-get install -y $INSTALL_PKGS && \
    apt-get clean 

RUN go get golang.org/x/tools/cmd/goimports

WORKDIR /tmp/_working_dir

COPY . .

RUN GOARCH=arm64 GOOS=linux CC=aarch64-linux-gnu-gcc make build

FROM arm64v8/alpine:latest

ENV OPERATOR=/usr/local/bin/jaeger-operator \
    USER_UID=1001 \
    USER_NAME=jaeger-operator

COPY --from=builder /tmp/_working_dir/scripts/* /scripts/
# install operator binary
COPY --from=builder /tmp/_working_dir/build/_output/bin/jaeger-operator ${OPERATOR}

ENTRYPOINT ["/usr/local/bin/jaeger-operator"]

USER ${USER_UID}
