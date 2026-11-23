#include <algorithm>

#include "Variant.h"

void Variant::addFlag(QString name) {
    auto meta = QMetaEnum::fromType<Enums::Flag>();
    m_flags |= Enums::Flags::fromInt(meta.keyToValue(name.toUpper().toUtf8().data()));
    Q_EMIT flagsChanged();
}
void Variant::removeFlag(QString name) {
    auto meta = QMetaEnum::fromType<Enums::Flag>();
    m_flags &= ~Enums::Flags::fromInt(meta.keyToValue(name.toUpper().toUtf8().data()));
    Q_EMIT flagsChanged();
}
QStringList Variant::flags() {
    auto meta = QMetaEnum::fromType<Enums::Flag>();
    QByteArray keys = meta.valueToKeys(m_flags);
    return QString::fromUtf8(keys).toLower().split(QLatin1Char('|'), Qt::SkipEmptyParts);
}
QStringList Variant::availableFlags() {
    auto meta = QMetaEnum::fromType<Enums::Flag>();
    QByteArray keys = meta.valueToKeys(~m_flags);
    return QString::fromUtf8(keys).toLower().split(QLatin1Char('|'), Qt::SkipEmptyParts);
}

void Variant::setSymbol(const QString keyname, const int level, const QString keysym) {
    const xkb_keycode_t keycode = xkb_get_keycode(keyname);
    KeyProps* props = m_keymap.value(keycode, nullptr);
    if (!props) {
        props = new KeyProps(this);
        m_keymap.insert(keycode, props);
    }
    const QString final = isImplicit(keysym.trimmed()) ? NOSYM : keysym.trimmed();
    props->symbols()->insert(level - 1, final);
}

QString Variant::getSymbol(const QString keyname, const int level) const {
    xkb_keycode_t keycode = xkb_get_keycode(keyname);
    KeyProps* props = m_keymap.value(keycode, nullptr);
    if (!props) {
        return {};
    }

    const QString result = props->symbols()->value(level - 1, {});
    return isImplicit(result) ? u""_s : result;
}

QString Variant::getSymbolOrFallback(QString keyname, int level, bool searchSelf) {
    return QStringLiteral();
}

QString Variant::toXkb() {
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
        QMap<xkb_keycode_t, int> explicitMap;

        // Pre-pass to determine width of every symbols column
        for (auto [keycode, keyprops] : m_keymap.asKeyValueRange()) {
            if (keyprops->symbols()->count() == 0)
                continue;
            int explicitCount = 0;
            for (int i = 0; i < keyprops->symbols()->count(); i++)
                if (!isImplicit(keyprops->symbols()->value(i)))
                    explicitCount = i + 1;
            explicitMap.insert(keycode, explicitCount);

            for (int i = 0; i < explicitCount; i++) {
                const QString symbol = quoteSymbol(keyprops->symbols()->value(i));
                columnWidths[i] = max((int)symbol.length(), columnWidths[i]);
            }
        }
        for (auto [keycode, keyprops] : m_keymap.asKeyValueRange()) {
            QStringList props;
            if (keyprops->symbols()->count() != 0) {
                QStringList symbols;
                for (int i = 0; i < explicitMap[keycode]; i++) {
                    QString symbol = quoteSymbol(keyprops->symbols()->value(i));
                    int width = columnWidths[i];

                    // if it's not the last explicit symbol
                    if (i < explicitMap[keycode] - 1) {
                        symbol += u","_s;
                        width += 5; // + 5 is 4 padding and 1 comma
                    }

                    symbols.append(symbol.leftJustified(width));
                }
                props.append(u"[ %1 ]"_s.arg(symbols.join(u""_s)));
            }
            if (!keyprops->type().isEmpty())
                props.append(u"type = \"%1\""_s.arg(keyprops->type()));
            if (!keyprops->repeat().isEmpty())
                props.append(u"repeat = \"%1\""_s.arg(keyprops->repeat()));
            if (!keyprops->virtmod().isEmpty())
                props.append(u"virtualModifiers = \"%1\""_s.arg(keyprops->virtmod()));

            const QString propsString = props.join(u",\n                   "_s);
            const QString keyname = xkb_get_keyname(keycode);
            lines.append(INDENT + u"key <%1> { %2 };"_s.arg(keyname).arg(propsString));
        }
    }

    lines.append(u"};"_s);
    return lines.join(u"\n").append(u"\n");
}
