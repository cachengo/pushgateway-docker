FROM alpine:3.8 as builder
COPY VERSION /VERSION
RUN VERSION=$(cat /VERSION) \
    && if test "$(uname -m)" = "aarch64" ; then ARCH="arm64"; else ARCH="amd64"; fi \
    && apk add --update ca-certificates openssl tar \
    && wget https://github.com/prometheus/pushgateway/releases/download/v${VERSION}/pushgateway-${VERSION}.linux-${ARCH}.tar.gz \
    && tar xzvf pushgateway-${VERSION}.linux-${ARCH}.tar.gz \
    && mv pushgateway-${VERSION}.linux-${ARCH}/pushgateway /bin/

FROM busybox:latest
COPY --from=builder /bin/pushgateway /bin/pushgateway
EXPOSE 9091
RUN mkdir -p /pushgateway
WORKDIR /pushgateway
ENTRYPOINT [ "/bin/pushgateway" ]
