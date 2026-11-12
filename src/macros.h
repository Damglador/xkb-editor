#pragma once

#include <QObject>
#include <string>

using namespace std;

#define NOSYM QStringLiteral("NoSymbol")

#define PROP(type, name, setter)                        \
public:                                                 \
    type name() const { return m_##name; }              \
    void setter(const type &value) {                    \
        if (m_##name != value) {                        \
            m_##name = value;                           \
            Q_EMIT name##Changed();                     \
        }                                               \
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

// https://stackoverflow.com/questions/1798112/removing-leading-and-trailing-spaces-from-a-string
inline string trim(const string& str, const string& ignored)
{
    const auto strBegin = str.find_first_not_of(ignored);
    if (strBegin == string::npos)
        return ""; // no content

    const auto strEnd = str.find_last_not_of(ignored);
    const auto strRange = strEnd - strBegin + 1;

    return str.substr(strBegin, strRange);
}
