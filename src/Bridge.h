#pragma once

#include <qobject.h>
#include <qqmlintegration.h>
#include <qtmetamacros.h>

#include "SymbolsFile.h"
#include "macros.h"

class Bridge : public QObject {
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

    Q_PROPERTY(SymbolsFile* file READ file CONSTANT)

    SymbolsFile* m_file = new SymbolsFile();
public:
    SymbolsFile* file() { return m_file; }

Q_SIGNALS:
    void fileChanged();
};
