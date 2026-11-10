#pragma once

#include "Include.h"
#include "List.h"

class IncludesList : public List {
    Q_OBJECT

    enum Roles {
        ObjectRole = Qt::UserRole + 1,
        PathRole = Qt::UserRole + 2,
        VariantRole = Qt::UserRole + 3,
    };

public:
    IncludesList(QObject* parent = nullptr) : List(parent) {};

    QHash<int, QByteArray> roleNames() const override {
        QHash<int, QByteArray> roles;
        roles[ObjectRole] = "include";
        roles[PathRole] = "path";
        roles[VariantRole] = "variant";
        return roles;
    }

    Include* getInclude(const int idx) const { return static_cast<Include*>(list.at(idx)); }

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override {
        if (!isValid(index))
            return QVariant();

        const int row = index.row();
        if (!isValid(row))
            return QVariant();

        switch (role) {
            case Qt::DisplayRole: return QVariant(getInclude(row)->toString());
            case ObjectRole: return QVariant::fromValue(getInclude(row));
            case PathRole: return QVariant(getInclude(row)->path());
            case VariantRole: return QVariant(getInclude(row)->variant());
        }
        return QVariant();
    }
};
