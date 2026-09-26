PO_FILES   = $(wildcard *.po)
QM_FILES   = $(patsubst  %.po, release/xkbeditor_%.qm, $(PO_FILES))

all: $(PO_FILES) $(QM_FILES)

xkbeditor.ts:
	pyside6-lupdate ../** -ts $@ -source-language en

xkbeditor.pot: xkbeditor.ts
	lconvert6 -i xkbeditor.ts -o xkbeditor.pot -drop-translations

%.po: xkbeditor.pot
	msgmerge --update --backup=none $@ $<

release/%.ts: %.po
	lconvert6 -i $< -o $@

release/xkbeditor_%.qm: release/%.ts
	pyside6-lrelease $< -qm $@
