.PHONY: build
build: translations
	cmake -S . -B build/
	cmake --build build/ -j $(nproc)

.PHONY: translations
translations:
	make -C translations/

.PHONY: test
test: build
	build/bin/test-types-include
	build/bin/test-types-variant
	build/bin/test-parser-xkb
	build/bin/test-parser-keysymdef

.PHONY: run
run: build
	build/bin/xkb-editor
