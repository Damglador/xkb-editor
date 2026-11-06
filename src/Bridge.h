#pragma once

#include <qobject.h>
#include <qqmlintegration.h>
#include <qtmetamacros.h>

#include "SymbolsFile.h"
#include "KeysymTable.h"
#include "macros.h"

class Bridge : public QObject {
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

    Q_PROPERTY(SymbolsFile* file READ file CONSTANT)
    Q_PROPERTY(KeysymTableModel* keysymTable READ keysymTable CONSTANT)

    SymbolsFile* m_file = new SymbolsFile;
    KeysymTableModel* m_keysymTable = new KeysymTableModel;
public:
    SymbolsFile* file() { return m_file; }
    KeysymTableModel* keysymTable() { return m_keysymTable; }

Q_SIGNALS:
    void fileChanged();
};
