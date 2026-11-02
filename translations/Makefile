RELEASE_DIR = ../xkbeditor/translations

PO_FILES   = $(wildcard *.po)
QM_FILES   = $(patsubst  %.po, $(RELEASE_DIR)/xkbeditor_%.qm, $(PO_FILES))

all: $(PO_FILES) $(RELEASE_DIR) $(QM_FILES)

$(RELEASE_DIR):
	mkdir -p $@

xkbeditor.ts:
	lupdate6 ../xkbeditor/qt/** -ts $@ -source-language en

xkbeditor.pot: xkbeditor.ts
	lconvert6 -i xkbeditor.ts -o xkbeditor.pot -drop-translations

%.po: xkbeditor.pot
	msgmerge --update --backup=none $@ $<

$(RELEASE_DIR)/%.ts: %.po
	lconvert6 -i $< -o $@

$(RELEASE_DIR)/xkbeditor_%.qm: $(RELEASE_DIR)/%.ts
	lrelease6 $< -qm $@
