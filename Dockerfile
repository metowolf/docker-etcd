FROM alpine:3.10 as builder

LABEL maintainer="metowolf <i@i-meto.com>"

ARG ETCD_VERSION=3.4.3

RUN set -ex \
  && apk update \
  && apk add --no-cache \
    upx \
  && wget https://github.com/etcd-io/etcd/releases/download/v${ETCD_VERSION}/etcd-v${ETCD_VERSION}-linux-amd64.tar.gz \
  && tar zxvf etcd-v${ETCD_VERSION}-linux-amd64.tar.gz \
  && cd etcd-v${ETCD_VERSION}-linux-amd64 \
  && upx etcd* \
  && mkdir -p /usr/local/etcd/bin \
  && mv etcd* /usr/local/etcd/bin


FROM alpine:3.10

LABEL maintainer="metowolf <i@i-meto.com>"

COPY --from=builder /usr/local/etcd /usr/local/etcd

RUN apk add --no-cache tzdata \
  && ln -s /usr/local/etcd/bin/etcd /usr/local/bin/etcd \
  && ln -s /usr/local/etcd/bin/etcdctl /usr/local/bin/etcdctl \
  && mkdir -p /var/etcd/ \
  && mkdir -p /var/lib/etcd/ \
  && echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf

EXPOSE 2379 2380

CMD ["/usr/local/bin/etcd"]
