#pragma once

#include <QAbstractItemModel>
#include <QObject>
#include <QVariant>
#include <filesystem>
#include <vector>

#include "getchar.h"
#include "parser/keysymdef_parser.h"

#define SYSHEADER "/usr/include/X11/keysymdef.h"

using namespace Qt::Literals::StringLiterals;

class KeysymTableModel : public QAbstractTableModel {
    Q_OBJECT

    vector<Item> m_items;
    QString m_doc;
    QString m_copyright;
    QString m_sourcePath;

    enum Roles {
        Name = Qt::UserRole + 0,
        Keysym = Qt::UserRole + 1,
        Character = Qt::UserRole + 2,
        Comment = Qt::UserRole + 3,
    };

public:
    KeysymTableModel(QObject* parent = nullptr) : QAbstractTableModel(parent) {
        if (std::filesystem::exists(SYSHEADER)) {
            m_items = tableFromFile(SYSHEADER);
            m_sourcePath = QStringLiteral(SYSHEADER);
        } // TODO: package the header

        if (m_items.size() > 1) {
            m_copyright = QString::fromStdString(m_items[0].comment);
            m_doc = QString::fromStdString(m_items[1].comment);
            m_items.erase(m_items.begin(), m_items.begin() + 2);
        }
    };

    Q_INVOKABLE QString copyright() { return m_copyright; };
    Q_INVOKABLE QString doc() { return m_doc; };
    Q_INVOKABLE QString sourcePath() { return m_sourcePath; }

    int rowCount(const QModelIndex &parent = QModelIndex()) const override {
        Q_UNUSED(parent);
        return m_items.size(); // TODO: return proper count of elements
    }
    int columnCount(const QModelIndex &parent = QModelIndex()) const override {
        Q_UNUSED(parent);
        return 4;
    }
    QVariant data(const QModelIndex &index, int role) const override {
        Q_UNUSED(role)
        int row = index.row();
        int column = index.column();
        // clang-format off
        switch (column + Qt::UserRole) {
        case Name:
            return QVariant(QString::fromStdString(m_items[row].name).remove(0, 3));
        case Keysym:
            return QVariant(QString::fromStdString(m_items[row].keysym));
        case Character:
            return QVariant(xkb_getchar(QString::fromStdString(m_items[row].keysym)));
        case Comment:
            return QVariant(QString::fromStdString(m_items[row].comment));
        default:
            return QVariant();
        }
        // clang-format on
    }
    QVariant headerData(int section, Qt::Orientation orientation,
                        int role = Qt::DisplayRole) const override {
        Q_UNUSED(role);
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
