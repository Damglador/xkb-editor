#pragma once

#include <qobject.h>

#define NOSYM QStringLiteral("NoSymbol")

#define PROP(type, name, setter)                        \
public:                                                 \
    type name() const { return m_##name; }              \
    void setter(const type &value) {                    \
        if (m_##name == value) return;                  \
        m_##name = value;                               \
        Q_EMIT name##Changed();                         \
    }                                                   \
Q_SIGNALS:                                              \
    void name##Changed();                               \
private:                                                \
    type m_##name;

inline bool isImplicit(QString symbol) {
    if (symbol.isEmpty() || symbol == NOSYM)
        return true;
    else
        return false;
}
