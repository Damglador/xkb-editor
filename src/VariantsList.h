#pragma once

#include <QAbstractListModel>
#include <QList>
#include <QVariant>
#include <qnamespace.h>
#include <qtmetamacros.h>

#include "List.h"
#include "Variant.h"

class VariantsList : public List {
    Q_OBJECT

    enum Roles {
        ObjectRole = Qt::UserRole + 1,
        IdRole = Qt::UserRole + 2,
        NameRole = Qt::UserRole + 3,
    };

public:
    VariantsList(QObject* parent = nullptr) : List(parent) {};

    QHash<int, QByteArray> roleNames() const override {
        QHash<int, QByteArray> roles;
        roles[ObjectRole] = "variant";
        roles[IdRole] = "id";
        roles[NameRole] = "name";
        return roles;
    }

    Variant* getVariant(const int idx) const { return static_cast<Variant*>(list.at(idx)); }

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override {
        if (!isValid(index))
            return QVariant();

        const int row = index.row();
        if (!isValid(row))
            return QVariant();

        switch (role) {
            case Qt::DisplayRole: return QVariant(getVariant(row)->id());
            case ObjectRole: return QVariant::fromValue(getVariant(row));
            case IdRole: return QVariant(getVariant(row)->id());
            case NameRole: return QVariant(getVariant(row)->name());
        }
        return QVariant();
    }
};
