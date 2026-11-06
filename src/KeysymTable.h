#pragma once

#include <QAbstractListModel>
#include <QObject>
#include <QtQmlIntegration>
#include <qabstractitemmodel.h>
#include <qobject.h>
#include <qtmetamacros.h>

using namespace Qt::Literals::StringLiterals;

class KeysymTableModel : public QAbstractTableModel {
    Q_OBJECT
public:
    explicit KeysymTableModel(QObject* parent = nullptr) : QAbstractTableModel(parent) {};
    Q_INVOKABLE QString getDoc() { return u"mega docs"_s; };
    Q_INVOKABLE QString getCopyright() { return u"mega copyright"_s; };


    int rowCount(const QModelIndex& parent = QModelIndex()) const override { return 0; }
    int columnCount(const QModelIndex& parent = QModelIndex()) const override { return 3; }
    QVariant data(const QModelIndex &index, int role) const override { return QVariant(); }

};
