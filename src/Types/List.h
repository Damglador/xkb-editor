#pragma once

#include <QAbstractListModel>
#include <QHash>
#include <QList>

class List : public QAbstractListModel {
    Q_OBJECT

protected:
    QList<QObject*> list;
    enum Roles {
        ObjectRole = Qt::UserRole + 1,
    };

public:
    List(QObject* parent = nullptr) : QAbstractListModel(parent) {};

    int rowCount(const QModelIndex &parent = QModelIndex()) const override {
        Q_UNUSED(parent);
        return list.count();
    }
    int count() const {
        return list.count();
    };
    int length() const {
        return list.length();
    };

    // bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole)
    // override {
    //     if (role == Qt::EditRole && isValid(index)) {
    //         list[index.row()] = value;
    //         dataChanged(index, index);
    //         return true;
    //     }
    //     return false;
    // }

    Q_INVOKABLE QObject* get(const int idx) const {
        if (isValid(idx)) {
            return list[idx];
        }
        return nullptr;
    }

    Q_INVOKABLE void remove(const int idx) {
        if (isValid(idx)) {
            beginRemoveRows(QModelIndex(), idx, idx);
            list.remove(idx);
            endRemoveRows();
        }
    }

    Q_INVOKABLE void move(const int from, const int to) {
        if (from == to || !isValid(from) || !isValid(to))
            return;

        int dest = to < from ? to : to + 1;
        beginMoveRows(QModelIndex(), from, from, QModelIndex(), dest);
        list.move(from, to);
        endMoveRows();
    }

    Q_INVOKABLE void clear() {
        beginResetModel();
        qDeleteAll(list);
        list.clear();
        endResetModel();
    }

    Q_INVOKABLE void insert(const int idx, QObject* obj) {
        if (!obj || 0 > idx || idx > list.count())
            return;

        obj->setParent(this);

        beginInsertRows(QModelIndex(), idx, idx);
        list.insert(idx, obj);
        endInsertRows();
    }

    Q_INVOKABLE void append(QObject* obj) { insert(list.length(), obj); }

    QHash<int, QByteArray> roleNames() const override {
        QHash<int, QByteArray> roles;
        roles[ObjectRole] = "modelData";
        return roles;
    }

    inline bool isValid(const QModelIndex &index) const {
        if (index.isValid() && 0 <= index.row() && index.row() < rowCount())
            return true;
        return false;
    }

    inline bool isValid(const int idx) const {
        if (0 <= idx && idx < rowCount())
            return true;
        return false;
    }
};
