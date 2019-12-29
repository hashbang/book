ARG HUGO_VERSION=0.62.0-ext-debian
ARG HUGO_DIGEST=sha256:a0560272a4936793d2c38961ac0ddfe692f2dd3d1a1914c1b9f4cc91cfc4ec12
ARG NGINX_VERSION=1.17.6

FROM klakegg/hugo:${HUGO_VERSION}@${HUGO_DIGEST} as builder

COPY . /src/site
WORKDIR /src/site/
RUN hugo --theme book -s .


FROM nginx:${NGINX_VERSION} as server

COPY --from=builder /src/site/public /usr/share/nginx/html
