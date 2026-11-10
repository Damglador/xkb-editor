#pragma once

#include <QObject>
#include <QtLogging>
#include <QtQmlIntegration>
#include <qtmetamacros.h>

#include "KeysymTable.h"
#include "SymbolsFile.h"
#include "getchar.h"
#include "macros.h"

class Bridge : public QObject {
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

    Q_PROPERTY(SymbolsFile* file READ file CONSTANT)
    Q_PROPERTY(KeysymTableModel* keysymTable READ keysymTable CONSTANT)

    SymbolsFile* m_file = new SymbolsFile(this);
    KeysymTableModel* m_keysymTable = new KeysymTableModel(this);

public:
    Bridge(QObject* parent = nullptr) : QObject(parent) {
        connect(this, &Bridge::error, this, &Bridge::print);
        connect(m_file, &SymbolsFile::error, this, &Bridge::error);
        connect(m_file, &SymbolsFile::fileLoaded, this, &Bridge::fileChanged);
    }
    SymbolsFile* file() { return m_file; }
    KeysymTableModel* keysymTable() { return m_keysymTable; }
    Q_SLOT void print(QString message) { qDebug() << message; }

    Q_INVOKABLE QString getSymbolChar(QString symbol) { return xkb_getchar(symbol); }

Q_SIGNALS:
    void fileChanged();
    void error(QString message);
    void notify(QString message);
};
