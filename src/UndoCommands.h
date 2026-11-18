#pragma once

#include <QObject>
#include <QUndoCommand>

#include "IncludesList.h"
#include "Variant.h"
#include "VariantsList.h"

using namespace Qt::Literals::StringLiterals;

namespace Command {
enum Command {
    AddVariant,
    RemoveVariant,
    AddFlag,
    RemoveFlag,
    AddInclude,
    RemoveInclude,
    EditText,
    SetSymbol,
};
}

// === VARIANTS
class AddVariant : public QUndoCommand {
    VariantsList* m_list;
    Variant* m_item;
    const QString m_id;
    const int m_index;

public:
    AddVariant(VariantsList* list, const QString id)
        : m_list(list), m_id(id), m_index(list->rowCount()) {
        setText(u"Add %1"_s.arg(id));
        m_item = new Variant();
        m_item->setId(m_id);
    };
    ~AddVariant() {
        if (!m_item->parent()) {
            qDebug() << "Deleting object of " << m_item->id();
            delete m_item;
        }
    }
    void undo() override { m_list->remove(m_index); }
    void redo() override { m_list->insert(m_index, m_item); }
};

class RemoveVariant : public QUndoCommand {
    VariantsList* m_list;
    Variant* m_item;
    const int m_index;

public:
    RemoveVariant(VariantsList* list, const int index)
        : m_list(list), m_item(list->get(index)), m_index(index) {
        setText(u"Remove %1"_s.arg(m_item->id()));
    };
    ~RemoveVariant() {
        if (!m_item->parent()) {
            qDebug() << "Deleting object of " << m_item->id();
            delete m_item;
        }
    }
    void undo() override { m_list->insert(m_index, m_item); }
    void redo() override { m_list->remove(m_index); }
};

// === FLAGS
class AddFlag : public QUndoCommand {
    Variant* m_variant;
    const QString m_flag;

public:
    AddFlag(Variant* variant, const QString flag) : m_variant(variant), m_flag(flag) {
        setText(u"Add %1"_s.arg(flag));
    };
    void undo() override { m_variant->removeFlag(m_flag); }
    void redo() override { m_variant->addFlag(m_flag); }
};

class RemoveFlag : public QUndoCommand {
    Variant* m_variant;
    QString m_flag;

public:
    RemoveFlag(Variant* variant, const QString flag) : m_variant(variant), m_flag(flag) {
        setText(u"Remove %1"_s.arg(flag));
    };
    void undo() override { m_variant->addFlag(m_flag); }
    void redo() override { m_variant->removeFlag(m_flag); }
};

// === INCLUDES
class AddInclude : public QUndoCommand {
    IncludesList* m_list;
    Include* m_item;
    const int m_index;

public:
    AddInclude(IncludesList* list, const QString string)
        : m_list(list), m_item(Include::fromString(string)), m_index(list->rowCount()) {
        setText(u"Add %1"_s.arg(m_item->toString()));
    };
    ~AddInclude() {
        if (!m_item->parent())
            delete m_item;
    }
    void undo() override { m_list->remove(m_index); }
    void redo() override { m_list->insert(m_index, m_item); }
};

class RemoveInclude : public QUndoCommand {
    IncludesList* m_list;
    Include* m_item;
    const int m_index;

public:
    RemoveInclude(IncludesList* list, const int index)
        : m_list(list), m_item(list->get(index)), m_index(index) {
        setText(u"Remove %1"_s.arg(m_item->toString()));
    };
    ~RemoveInclude() {
        if (!m_item->parent()) {
            qDebug() << "Deleting object of " << m_item->toString();
            delete m_item;
        }
    }
    void undo() override { m_list->insert(m_index, m_item); }
    void redo() override { m_list->remove(m_index); }
};

class EditText : public QUndoCommand {
public:
    QObject* m_target;
    const QByteArray m_property;
    QString m_newText;
    const QString m_oldText;

public:
    EditText(QObject* target, const QString property, const QString newText)
        : m_target(target), m_property(property.toLocal8Bit()), m_newText(newText), m_oldText(m_target->property(m_property.constData()).toString()) {
        setText(m_oldText + u" → "_s + m_newText);
    };
    void undo() override { m_target->setProperty(m_property.constData(), QVariant(m_oldText)); }
    void redo() override { m_target->setProperty(m_property.constData(), QVariant(m_newText)); }

    int id() const override { return Command::EditText; }

    bool mergeWith(const QUndoCommand* other) override {
        if (id() != other->id())
            return false;
        const EditText* command = static_cast<const EditText*>(other);

        if (m_target != command->m_target) {
            return false;
        }
        if (m_property != command->m_property) {
            return false;
        }

        m_newText = command->m_newText;
        setText(m_oldText + u" → "_s + m_newText);

        if (m_newText == m_oldText)
            setObsolete(true);

        return true;
    }
};

class SetSymbol : public QUndoCommand {
    Variant* m_variant;
    const QString m_keyname;
    const int m_level;
    const QString m_newKeysym;
    const QString m_oldKeysym;

public:
    SetSymbol(Variant* variant, QString keyname, int level, QString keysym)
        : m_variant(variant), m_keyname(keyname), m_level(level), m_newKeysym(keysym),
          m_oldKeysym(variant->getSymbol(keyname, level)) {
        setText(u"Set keysym of %1 to %2"_s.arg(keyname).arg(keysym));
    };
    void undo() override {
        m_variant->setSymbol(m_keyname, m_level, m_oldKeysym);
        Q_EMIT m_variant->symbolsChanged();
    }
    void redo() override {
        m_variant->setSymbol(m_keyname, m_level, m_newKeysym);
        Q_EMIT m_variant->symbolsChanged();
    }
};
