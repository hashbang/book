VERSION=latest

.PHONY: setup
setup:
	docker build -t book-builder --target=builder .

.PHONY: dev-server
dev-server:
	docker run \
		-v $$PWD/:/src/site \
		-p 1313:1313 \
		book-builder -- cd /src/site && hugo server --minify --theme book

.PHONY: image
image:
	docker build $(BUILD_ARGS) -t hashbang/book:$(VERSION) .
