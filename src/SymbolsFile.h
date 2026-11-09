#pragma once

#include <qdir.h>
#include <qlist.h>
#include <qobject.h>
#include <qqmlintegration.h>
#include <qtmetamacros.h>
#include <qurl.h>

#include "Variant.h"
#include "VariantsList.h"
#include "macros.h"

using namespace Qt::Literals::StringLiterals;

class SymbolsFile : public QObject {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString  path            READ path         WRITE setPath         NOTIFY pathChanged)
    Q_PROPERTY(VariantsList* variants READ variants     CONSTANT)
    Q_PROPERTY(Variant* variant         READ variant                            NOTIFY variantChanged)
    Q_PROPERTY(int variantIndex         READ variantIndex WRITE setVariantIndex NOTIFY variantChanged)
    PROP(int, variantIndex, setVariantIndex)
    PROP(QString, path, setPath)

private:
    VariantsList* m_variants = new VariantsList();
    Variant* m_variant = nullptr;
    void updateVariant() {
        if (0 <= m_variantIndex && m_variantIndex < m_variants->rowCount()) {
            m_variant = m_variants->getVariant(m_variantIndex);
        } else {
            m_variant = nullptr;
        }
        Q_EMIT variantChanged();
    }

public:
    SymbolsFile(QObject* parent = nullptr) : QObject(parent) {};
    VariantsList* variants() { return m_variants; }
    Variant* variant() { return m_variant; }

    Q_INVOKABLE void load(QString filePath) {
        error(u"Test error"_s);
    }

    Q_INVOKABLE void clear() {
        setPath(u""_s);
        setVariantIndex(0);
        m_variants->clear();
    }

Q_SIGNALS:
    void error(QString message);

    void fileLoaded();
    void variantChanged();
};
