#pragma once

#include <QObject>
#include <QUndoCommand>

#include "Variant.h"
#include "VariantsList.h"

using namespace Qt::Literals::StringLiterals;

class AddVariant : public QUndoCommand {
    VariantsList* m_variants;
    const QString m_id;
    const int m_index;

public:
    AddVariant(VariantsList* variants, const QString id)
        : m_variants(variants), m_id(id), m_index(variants->rowCount()) {
        setText(u"Add %1"_s.arg(id));
    };
    void undo() override { m_variants->remove(m_index); }
    void redo() override {
        Variant* variant = new Variant();
        variant->setId(m_id);
        m_variants->insert(m_index, variant);
    }
};
