#pragma once

#include <QObject>
#include <QtQmlIntegration>
#include <QAbstractItemModel>
#include <QVariant>
#include <qnamespace.h>
#include <qtmetamacros.h>

using namespace Qt::Literals::StringLiterals;

class KeysymTableModel : public QAbstractTableModel {
    Q_OBJECT
public:
    explicit KeysymTableModel(QObject* parent = nullptr) : QAbstractTableModel(parent) {};
    Q_INVOKABLE QString getDoc() { return u"mega docs"_s; };
    Q_INVOKABLE QString getCopyright() { return u"mega copyright"_s; };


    int rowCount(const QModelIndex& parent = QModelIndex()) const override {
        return 0; // TODO: return proper count of elements
    }
    int columnCount(const QModelIndex& parent = QModelIndex()) const override {
        return 4;
    }
    QVariant data(const QModelIndex &index, int role) const override {
        return QVariant(); // TODO: return proper data
    }
    QVariant headerData(int section, Qt::Orientation orientation, int _ = Qt::DisplayRole) const override {
        if (orientation == Qt::Orientation::Horizontal) {
            switch (section) {
                case 0: return u"Name"_s;
                case 1: return u"Keysym"_s;
                case 2: return u"Character"_s;
                case 3: return u"Comment"_s;
            }
        }
        return QVariant();
    }

};
