# https://invent.kde.org/frameworks/ki18n/-/blob/master/docs/programmers-guide.md?ref_type=heads
EXTOPTS = --c++ --kde \
--from-code=UTF-8 \
-ci18n \
-ki18n:1 -ki18nc:1c,2 -ki18np:1,2 -ki18ncp:1c,2,3 \
-kki18n:1 -kki18nc:1c,2 -kki18np:1,2 -kki18ncp:1c,2,3 \
-kkli18n:1 -kkli18nc:1c,2 -kkli18np:1,2 -kkli18ncp:1c,2,3 \
-kI18N_NOOP:1 -kI18NC_NOOP:1c,2 \
--copyright-holder="Vsevolod «Damglador» Stopchanskyi" \
--msgid-bugs-address=https://github.com/Damglador/xkb-editor/issues \
--package-name=xkb-editor

.PHONY: build
build: pot
	cmake -B build/
	cmake --build build/ --parallel

.PHONY: pot
pot:
	find src/ -name *.cpp -o -name *.h -o -name *.qml | sort | xargs xgettext ${EXTOPTS} -o po/xkb-editor.pot

.PHONY: test
test:
	cmake -B build/ -D BUILD_TESTING=YES
	cmake --build build/ --parallel
	build/bin/test-types-include
	build/bin/test-types-variant
	build/bin/test-parser-xkb
	build/bin/test-parser-keysymdef

.PHONY: run
run: build
	build/bin/xkb-editor
