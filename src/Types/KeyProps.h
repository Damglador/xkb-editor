#pragma once

#include <QList>
#include <QObject>
#include <algorithm>

#include "macros.h"

using namespace Qt::Literals::StringLiterals;

class KeyProps : public QObject {
    Q_OBJECT

    // clang-format off
    Q_PROPERTY(QStringList  symbols  READ symbols    WRITE setSymbols    NOTIFY symbolsChanged)
    // Q_PROPERTY(QString      actions  READ actions    WRITE setActions    NOTIFY actionsChanged)
    QStringList m_symbols = { NOSYM, NOSYM, NOSYM, NOSYM };
    QStringList m_actions;
    PROP(QString,  virtmod,  setVirtmod)
    PROP(QString,  repeat,   setRepeat)
    PROP(QString,  type,     setType)
    // clang-format on

public:
    KeyProps(QObject* parent = nullptr) : QObject(parent) {};

    QStringList symbols() { return m_symbols; }
    QStringList* symbolsP() { return &m_symbols; }
    void setSymbols(const QStringList value) {
        bool changed = false;
        for (int i = 0; i < std::min(value.length(), m_symbols.length()); i++) {
            if (!isImplicit(value[i])) {
                m_symbols[i] = value[i];
                changed = true;
            }
        }
        if (changed)
            Q_EMIT symbolsChanged();
    }
Q_SIGNALS:
    void symbolsChanged();
    void actionsChanged();
};
