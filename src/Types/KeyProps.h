#pragma once

#include <algorithm>
#include <qcontainerfwd.h>
#include <qflags.h>
#include <qhashfunctions.h>
#include <qlist.h>
#include <qmetaobject.h>
#include <QtQml/qqmlregistration.h>
#include <qobject.h>
#include <qtmetamacros.h>
#include <qurl.h>

#include "macros.h"

using namespace Qt::Literals::StringLiterals;


class KeyProps : public QObject {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QStringList symbols  READ symbols    WRITE setSymbols    NOTIFY symbolsChanged)
    // Q_PROPERTY(QString actions      READ actions    WRITE setActions    NOTIFY actionsChanged)
    QStringList m_symbols = { NOSYM, NOSYM, NOSYM, NOSYM };
    QStringList m_actions;
    PROP(QString, virtmod, setVirtmod)
    PROP(bool, repeat, setRepeat)
    PROP(QString, type, setType)

    QStringList symbols() { return m_symbols; }
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
