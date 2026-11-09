#pragma once

#include <QHashFunctions>
#include <QList>
#include <QMetaEnum>
#include <QObject>
#include <QtContainerFwd>
#include <QtQml/qqmlregistration.h>
#include <qtmetamacros.h>

#include "Enums.h"
#include "Include.h"
#include "KeyProps.h"
#include "macros.h"

using namespace Qt::Literals::StringLiterals;

class Variant : public QObject {
    Q_OBJECT

    Q_PROPERTY(QString id               READ id         WRITE setId         NOTIFY idChanged)
    Q_PROPERTY(QString name             READ name       WRITE setName       NOTIFY nameChanged)
    Q_PROPERTY(QStringList flags        READ flags                          NOTIFY flagsChanged)
    Q_PROPERTY(QMap<QString, KeyProps*> keymap           READ keymap                         NOTIFY keymapChanged)
    Q_PROPERTY(QList<Include*> includes READ includes                       NOTIFY includesChanged)
    Q_PROPERTY(QString keytype          READ keytype    WRITE setKeytype    NOTIFY keytypeChanged)
    Q_PROPERTY(QString source           READ source     WRITE setSource     NOTIFY sourceChanged)

    PROP(QString, id,       setId)
    PROP(QString, name,     setName)
    Enums::Flags m_flags;
    QMap<QString, KeyProps*> m_keymap; // TODO: come up with a proper type
    QList<Include*> m_includes;
    PROP(QString, keytype,  setKeytype)
    PROP(QString, source,   setSource)
public:
    void addFlag(QString name) {
        auto meta = QMetaEnum::fromType<Enums::Flag>();
        m_flags |= Enums::Flags::fromInt(meta.keyToValue(name.toUpper().toUtf8().data()));
        Q_EMIT flagsChanged();
    }
    void removeFlag(QString name) {
        auto meta = QMetaEnum::fromType<Enums::Flag>();
        m_flags &= ~Enums::Flags::fromInt(meta.keyToValue(name.toUpper().toUtf8().data()));
        Q_EMIT flagsChanged();
    }
    QStringList flags() {
        auto meta = QMetaEnum::fromType<Enums::Flag>();
        QByteArray keys = meta.valueToKeys(m_flags);
        return QString::fromUtf8(keys).toLower().split(QLatin1Char('|'), Qt::SkipEmptyParts);
    }

    QList<Include*> includes() { return m_includes; }
    QMap<QString, KeyProps*> keymap() { return m_keymap; }

Q_SIGNALS:
    void flagsChanged();
    void keymapChanged();
    void includesChanged();
};
