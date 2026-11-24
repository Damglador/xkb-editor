#pragma once

#include <QFile>
#include <QList>
#include <QObject>
#include <QtQmlIntegration>

#include "Variant.h"
#include "VariantsList.h"
#include "macros.h"

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
    Q_SLOT void updateVariant();

public:
    SymbolsFile(QObject* parent = nullptr);
    VariantsList* variants() { return &m_variants; }
    Variant* variant() { return m_variant; }

    Q_INVOKABLE bool load(QString filePath);
    Q_INVOKABLE bool write(QString filePath);

    Q_INVOKABLE void clear();
    Q_INVOKABLE QString toXkb();

Q_SIGNALS:
    void error(QString message);

    void fileLoaded();
    void variantChanged();
};
