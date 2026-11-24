#pragma once

#include <QObject>
#include <xkbcommon/xkbcommon.h>

#include "Enums.h"
#include "IncludesList.h"
#include "KeyProps.h"
#include "macros.h"

using namespace Qt::Literals::StringLiterals;

#define Keymap QMap<xkb_keycode_t, KeyProps*>

class Variant : public QObject {
    Q_OBJECT

    // clang-format off
    Q_PROPERTY(QString        id                READ id         WRITE setId         NOTIFY idChanged     )
    Q_PROPERTY(QString        name              READ name       WRITE setName       NOTIFY nameChanged   )
    Q_PROPERTY(QString        keytype           READ keytype    WRITE setKeytype    NOTIFY keytypeChanged)
    Q_PROPERTY(QString        source            READ source     WRITE setSource     NOTIFY sourceChanged )
    Q_PROPERTY(QStringList    flags             READ flags                          NOTIFY flagsChanged  )
    Q_PROPERTY(QStringList    availableFlags    READ availableFlags                 NOTIFY flagsChanged  )
    Q_PROPERTY(IncludesList*  includes          READ includes   CONSTANT)
    Q_PROPERTY(Keymap*        keymap            READ keymap     CONSTANT)

    PROP(QString, id,       setId)
    PROP(QString, name,     setName)
    PROP(QString, keytype,  setKeytype)
    PROP(QString, source,   setSource)
    Enums::Flags m_flags;
    IncludesList m_includes = IncludesList(this);
    Keymap m_keymap;
    // clang-format on

public:
    Variant(QObject* parent = nullptr) : QObject(parent) {};

    void addFlag(QString name);
    void removeFlag(QString name);
    QStringList flags();
    QStringList availableFlags();

    IncludesList* includes() { return &m_includes; }
    Keymap* keymap() { return &m_keymap; }

    Q_INVOKABLE void setSymbol(const QString keyname, const int level, const QString keysym);
    Q_INVOKABLE QString getSymbol(const QString keyname, const int level) const;
    Q_INVOKABLE QString getSymbolOrFallback(QString keyname, int level, bool searchSelf = false);

    Q_INVOKABLE void reloadIncludes() { Q_EMIT includesReloaded(); }

    Q_INVOKABLE QString toXkb();

Q_SIGNALS:
    void flagsChanged();
    void symbolsChanged();
    void includesReloaded();
};
