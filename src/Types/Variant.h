#pragma once

#include <QList>
#include <QMetaEnum>
#include <QObject>

#include "Enums.h"
#include "IncludesList.h"
#include "KeyProps.h"
#include "macros.h"

using namespace Qt::Literals::StringLiterals;

class Variant : public QObject {
    Q_OBJECT

    // clang-format off
    Q_PROPERTY(QString                  id          READ id         WRITE setId         NOTIFY idChanged)
    Q_PROPERTY(QString                  name        READ name       WRITE setName       NOTIFY nameChanged)
    Q_PROPERTY(QString                  keytype     READ keytype    WRITE setKeytype    NOTIFY keytypeChanged)
    Q_PROPERTY(QString                  source      READ source     WRITE setSource     NOTIFY sourceChanged)
    Q_PROPERTY(QStringList              flags       READ flags                          NOTIFY flagsChanged)
    Q_PROPERTY(IncludesList*            includes    READ includes                       NOTIFY includesChanged)
    Q_PROPERTY(QMap<QString, KeyProps*> keymap      READ keymap                         NOTIFY keymapChanged)

    PROP(QString, id,       setId)
    PROP(QString, name,     setName)
    PROP(QString, keytype,  setKeytype)
    PROP(QString, source,   setSource)
    Enums::Flags m_flags;
    IncludesList* m_includes;
    QMap<QString, KeyProps*> m_keymap;
    // clang-format on

public:
    Variant(QObject* parent = nullptr) : QObject(parent) {};

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

    IncludesList* includes() { return m_includes; }
    QMap<QString, KeyProps*> keymap() { return m_keymap; }

    Q_INVOKABLE void setSymbol(const QString keycode, const int level, const QString keysym) {
        KeyProps* props = m_keymap.value(keycode, nullptr);
        if (!props) {
            props = new KeyProps(this);
        }
        props->symbolsP()->insert(level - 1,
                                  isImplicit(keysym.trimmed()) ? NOSYM : keysym.trimmed());
        m_keymap.insert(keycode, props); // if there wasn't such a keycode, it adds it, otherwise
                                         // shouldn't make a difference
    }

    Q_INVOKABLE QString getSymbol(const QString keycode, const int level) const {
        KeyProps* props = m_keymap.value(keycode, nullptr);
        if (!props) {
            return {};
        }

        const QString result = props->symbolsP()->value(level - 1, {});
        return isImplicit(result) ? u""_s : result;
    }

Q_SIGNALS:
    void flagsChanged();
    void keymapChanged();
    void includesChanged();
};
