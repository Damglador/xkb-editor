#pragma once

#include <QMetaEnum>
#include <QObject>
#include <algorithm>

#include "Enums.h"
#include "IncludesList.h"
#include "KeyProps.h"
#include "macros.h"

using namespace Qt::Literals::StringLiterals;

#define Keymap QMap<QString, KeyProps*>

class Variant : public QObject {
    Q_OBJECT

    // clang-format off
    Q_PROPERTY(QString        id          READ id         WRITE setId         NOTIFY idChanged     )
    Q_PROPERTY(QString        name        READ name       WRITE setName       NOTIFY nameChanged   )
    Q_PROPERTY(QString        keytype     READ keytype    WRITE setKeytype    NOTIFY keytypeChanged)
    Q_PROPERTY(QString        source      READ source     WRITE setSource     NOTIFY sourceChanged )
    Q_PROPERTY(QStringList    flags       READ flags                          NOTIFY flagsChanged  )
    Q_PROPERTY(IncludesList*  includes    READ includes   CONSTANT)
    Q_PROPERTY(Keymap         keymap      READ keymap     CONSTANT)

    PROP(QString, id,       setId)
    PROP(QString, name,     setName)
    PROP(QString, keytype,  setKeytype)
    PROP(QString, source,   setSource)
    Enums::Flags m_flags;
    IncludesList m_includes = IncludesList(this);
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

    IncludesList* includes() { return &m_includes; }
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

    Q_INVOKABLE QString toXkb() {
        QStringList lines;
        if (flags().length() != 0)
            lines.append(flags().join(u" "_s));
        lines.append(u"xkb_symbols \"%1\" {"_s.arg(m_id));

        if (!m_name.isEmpty()) {
            lines.append(INDENT + u"name[Group1] = \"%1\";"_s.arg(m_name));
            lines.append(u""_s);
        }
        if (!m_keytype.isEmpty())
            lines.append(INDENT + u"key.type = \"%1\";"_s.arg(m_keytype));
        if (m_includes.count() != 0) {
            for (int i = 0; i < m_includes.count(); i++) {
                Include* include = m_includes.getInclude(i);
                if (!include->path().isEmpty())
                    lines.append(INDENT + u"include \"%1\""_s.arg(include->toString()));
            }
        }
        if (!m_keymap.isEmpty()) {
            int columnWidths[] = { 0, 0, 0, 0, 0, 0, 0, 0 };
            QMap<QString, int> explicitMap;

            // Pre-pass to determine width of every symbols column
            for (auto [keycode, keyprops] : m_keymap.asKeyValueRange()) {
                if (keyprops->symbols().count() == 0)
                    continue;
                int explicitCount = 0;
                for (int i = 0; i < keyprops->symbols().count(); i++)
                    if (!isImplicit(keyprops->symbols()[i]))
                        explicitCount = i + 1;
                explicitMap.insert(keycode, explicitCount);

                for (int i = 0; i < explicitCount; i++) {
                    const QString symbol = quoteSymbol(keyprops->symbols()[i]);
                    columnWidths[i] = max((int)symbol.length(), columnWidths[i]);
                }
            }
            for (auto [keycode, keyprops] : m_keymap.asKeyValueRange()) {
                QStringList props;
                if (keyprops->symbols().count() != 0) {
                    QStringList symbols;
                    for (int i = 0; i < explicitMap[keycode]; i++) {
                        const QString symbol = quoteSymbol(keyprops->symbols()[i]);

                        if (i < explicitMap[keycode] - 1) // + 5 is 4 padding and 1 comma
                            symbols.append(QString(symbol + u","_s).leftJustified(columnWidths[i] + 5));
                        else
                            symbols.append(symbol.leftJustified(columnWidths[i]));
                    }
                    props.append(u"[ %1 ]"_s.arg(symbols.join(u""_s)));
                }
                if (!keyprops->type().isEmpty())
                    props.append(u"type = \"%1\""_s.arg(keyprops->type()));
                if (!keyprops->repeat().isEmpty())
                    props.append(u"repeat = \"%1\""_s.arg(keyprops->repeat()));
                if (!keyprops->virtmod().isEmpty())
                    props.append(u"virtualModifiers = \"%1\""_s.arg(keyprops->virtmod()));

                QString propsString = props.join(u",\n                   "_s);
                lines.append(INDENT + u"key <%1> { %2 }"_s.arg(keycode).arg(propsString));
            }
        }

        lines.append(u"};"_s);
        return lines.join(u"\n").append(u"\n");
    }

Q_SIGNALS:
    void flagsChanged();
};
