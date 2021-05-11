# buster
ARG GOLANG_DIGEST=sha256:8f7c5b9000f0531bb28860dc1232ca0defa346361e2003dbf324982407cfe927

# 1.21.0
ARG NGINX_DIGEST=sha256:61191087790c31e43eb37caa10de1135b002f10c09fdda7fa8a5989db74033aa

FROM golang@${GOLANG_DIGEST} as builder
ARG HUGO_VERSION=0.83.1
RUN \
  wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_Linux-64bit.deb \
  && dpkg -i hugo_extended_${HUGO_VERSION}_Linux-64bit.deb
COPY . /src/site/
WORKDIR /src/site/
RUN hugo --theme book -d /src/site/public -s .
CMD ["/usr/local/bin/hugo", "server", "--bind", "0.0.0.0"]


FROM nginx@${NGINX_DIGEST} as server
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
