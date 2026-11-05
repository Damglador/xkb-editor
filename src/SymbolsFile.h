#pragma once

#include <qdir.h>
#include <qlist.h>
#include <qqmlintegration.h>
#include <qobject.h>
#include <qtmetamacros.h>
#include <qurl.h>

#include "Variant.h"
#include "macros.h"

using namespace Qt::Literals::StringLiterals;

class SymbolsFile : public QObject {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString  path     READ path         WRITE setPath         NOTIFY pathChanged)
    Q_PROPERTY(QRangeModel* variants READ variants     CONSTANT)
    Q_PROPERTY(Variant* variant  READ variant                            NOTIFY variantChanged)
    Q_PROPERTY(int variantIndex READ variantIndex WRITE setVariantIndex NOTIFY variantChanged)
    PROP(int, variantIndex, setVariantIndex)
    PROP(QString, path, setPath)

private:
    QList<Variant*> m_variants;
    QRangeModel* m_variantsModel = new QRangeModel(&m_variants);
    Variant* m_variant;
    void updateVariant() {
        if (0 <= m_variantIndex && m_variantIndex < m_variants.length()) {
            m_variant = m_variants[m_variantIndex];
        } else {
            m_variant = nullptr;
        }
        Q_EMIT variantChanged();
    }
public:
    QList<Variant*> variants() { return m_variants; }
    QRangeModel* variants() { return m_variantsModel; }
    Variant* variant() { return m_variant; }

    Q_INVOKABLE void load(QString filePath) {
        // TODO
    }

    Q_INVOKABLE void clear() {
        setPath(u""_s);
        setVariantIndex(0);
        m_variants.clear();
        // TODO: clear variants
    }


Q_SIGNALS:
    void error(QString message);

    void fileLoaded();
    void variantChanged();
};
