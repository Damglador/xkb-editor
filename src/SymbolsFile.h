#pragma once

#include <QFile>
#include <QList>
#include <QObject>
#include <QUrl>
#include <qqmlintegration.h>

#include "Variant.h"
#include "VariantsList.h"
#include "macros.h"
#include "parser/xkb.h"

using namespace Qt::Literals::StringLiterals;

class SymbolsFile : public QObject {
    Q_OBJECT
    QML_ELEMENT

    // clang-format off
    Q_PROPERTY(QString        path            READ path          WRITE setPath          NOTIFY pathChanged)
    Q_PROPERTY(VariantsList*  variants        READ variants      CONSTANT)
    Q_PROPERTY(Variant*       variant         READ variant                              NOTIFY variantChanged)
    Q_PROPERTY(int            variantIndex    READ variantIndex  WRITE setVariantIndex  NOTIFY variantChanged)
    PROP(int,     variantIndex, setVariantIndex)
    PROP(QString, path,         setPath)
    // clang-format on

private:
    VariantsList m_variants = VariantsList(this);

    Variant* m_variant = nullptr;
    Q_SLOT void updateVariant() {
        if (0 <= m_variantIndex && m_variantIndex < m_variants.rowCount()) {
            m_variant = m_variants.get(m_variantIndex);
        } else {
            m_variant = nullptr;
        }
        Q_EMIT variantChanged();
    }

public:
    SymbolsFile(QObject* parent = nullptr) : QObject(parent) {
        connect(this, &SymbolsFile::variantIndexChanged, this, &SymbolsFile::updateVariant);
        connect(&m_variants, &VariantsList::rowsRemoved, this, &SymbolsFile::updateVariant);
        connect(&m_variants, &VariantsList::rowsInserted, this, &SymbolsFile::updateVariant);
        connect(&m_variants, &VariantsList::modelReset, this, &SymbolsFile::updateVariant);
    };
    VariantsList* variants() { return &m_variants; }
    Variant* variant() { return m_variant; }

    Q_INVOKABLE bool load(QString filePath) {
        // TODO: check if a file is a binary and catch parse failures
        QString path = QUrl(filePath).path();

        QList<Variant*> variants;

        int result = variantsFromFile(path, &variants, &m_variants);

        switch (result) {
        case ERROR_PARSING: Q_EMIT error(u"Failed to parse file."_s); return false;
        case ERROR_OPEN_FILE: Q_EMIT error(u"Failed to open file."_s); return false;
        case ERROR_EMPTY_FILE: Q_EMIT error(u"Empty file."_s); return false;
        }

        m_variants.setItems(variants);
        setVariantIndex(0);
        setPath(path);
        fileLoaded();
        return true;
    }
    Q_INVOKABLE bool write(QString filePath) {
        QFile file(QUrl(filePath).path());
        if (!file.open(QFile::WriteOnly | QFile::Text)) {
            Q_EMIT error(u"Failed to open file."_s);
            return false;
        }
        QStringList variants;
        for (int i = 0; i < m_variants.length(); i++) {
            variants.append(m_variants.get(i)->toXkb());
        }
        QTextStream stream(&file);
        stream << variants.join(u"\n"_s);
        file.close();

        return true;
    }

    Q_INVOKABLE void clear() {
        setPath(u""_s);
        setVariantIndex(0);
        m_variants.clear();
        Q_EMIT fileLoaded();
    }

Q_SIGNALS:
    void error(QString message);

    void fileLoaded();
    void variantChanged();
};
