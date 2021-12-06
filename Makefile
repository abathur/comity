prefix ?= /usr/local
bindir ?= ${prefix}/bin

.PHONY: build install uninstall check

build:
	# caution: below is meant to be run out of tree in nix
	./enumerate_signals.bash >> comity.bash

install:
	mkdir -p ${DESTDIR}${bindir}
	install comity.bash ${DESTDIR}${bindir}

uninstall:
	rm -f ${DESTDIR}${bindir}/comity.bash

# excluding SC1091 (finding a sourced file) for now because it requires bashup.events to be on the path
check:
	shellcheck -x -e SC1091 -e SC1078 -e SC1079 -e SC2086 ./comity.bash
	bats --timing tests/behavior.bats
