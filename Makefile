ifeq ($(PREFIX),)
	PREFIX := /usr/local
endif

all: release

.PHONY: clean
clean:
	rm -f swayfocus

.PHONY: run
run:
	crystal run src/swayfocus.cr

release:
	crystal build --release --no-debug src/swayfocus.cr

install:
	install swayfocus $(PREFIX)/bin/
