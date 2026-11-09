#pragma once

#include <QUndoCommand>
#include <QObject>

#include "Variant.h"
#include "VariantsList.h"

using namespace Qt::Literals::StringLiterals;

class AddVariant : public QUndoCommand {
    VariantsList* variants;
    const QString id;
    const int index;
public:
    AddVariant(VariantsList* _variants, const QString _id)
        : variants(_variants), id(_id), index(_variants->rowCount()) {
        setText(u"Add %1"_s.arg(id));
    };
    void undo() override { variants->remove(index); }
    void redo() override {
        if (!variants->insertRows(index, 1))
            return;
        Variant* variant = new Variant();
        variant->setId(id);
        variants->insert(index, variant);
    }
};
