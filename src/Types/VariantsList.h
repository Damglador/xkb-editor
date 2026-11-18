#pragma once

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

    void setItems(QList<Variant*> items) {
        clear();
        beginResetModel();
        for (Variant* variant : items) {
            variant->setParent(this);
            list.append(variant);
        }
        endResetModel();
    }

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override {
        if (!isValid(index))
            return QVariant();

        const int row = index.row();
        if (!isValid(row))
            return QVariant();

        switch (role) {
        case Qt::DisplayRole: return QVariant(get(row)->id());
        case ObjectRole: return QVariant::fromValue(get(row));
        case IdRole: return QVariant(get(row)->id());
        case NameRole: return QVariant(get(row)->name());
        }
        return QVariant();
    }

    Q_INVOKABLE Variant* get(const int idx) const {
        if (isValid(idx)) {
            return static_cast<Variant*>(list[idx]);
        }
        return nullptr;
    }
};
