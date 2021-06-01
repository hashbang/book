VERSION := $(shell git describe --tags --always)

.PHONY:
submodule:
	git submodule update --init --recursive

.PHONY: setup
setup: submodule
	docker build -t book-builder --target=builder .

.PHONY: dev-server
dev-server:
	docker run \
		-v $(PWD)/:/src/site \
		-p 1313:1313 \
		book-builder

.PHONY: image
image:
	docker build \
		$(BUILD_ARGS) \
		-t hashbang/book:$(VERSION) \
		.
