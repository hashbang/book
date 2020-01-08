ARG GOLANG_VERSION=buster
ARG GOLANG_DIGEST=sha256:544b2d0378d9de9a8ade9cebd9a333e60cc8343f9d3dd01ccccfc4c1395ce132
ARG DEBIAN_VERSION=buster-slim
ARG DEBIAN_DIGEST=sha256:0c679627b3a61b2e3ee902ec224b0505839bc2ad76d99530e5f0566e47ac8400

FROM golang:${GOLANG_VERSION}@${GOLANG_DIGEST} as builder
ARG HUGO_VERSION=0.62.1
RUN \
  wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_Linux-64bit.deb \
  && dpkg -i hugo_extended_${HUGO_VERSION}_Linux-64bit.deb
COPY . /src/site/
WORKDIR /src/site/
RUN hugo --theme book -d /src/site/public -s .
CMD ["/usr/local/bin/hugo", "server", "--bind", "0.0.0.0"]


FROM debian:${DEBIAN_VERSION}@${DEBIAN_DIGEST} as server
RUN apt-get update && apt-get install -y nginx
COPY --from=builder /src/site/public/ /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/nginx.conf
RUN \
  touch /run/nginx.pid \
  && chown -R www-data:www-data \
    /run/nginx.pid

EXPOSE 8080
STOPSIGNAL SIGTERM

USER www-data

ENTRYPOINT ["/usr/sbin/nginx"]
CMD ["-g", "daemon off;"]
