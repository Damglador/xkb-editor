#include <QList>
#include <QUndoStack>
#include <QtQml/qqmlregistration.h>
#include <qtmetamacros.h>

#include "IncludesList.h"
#include "UndoCommands.h"
#include "VariantsList.h"

class UndoStack : public QUndoStack {
    Q_OBJECT
    QML_ELEMENT
public:
    Q_INVOKABLE void clear() { QUndoStack::clear(); }
    Q_INVOKABLE bool isClean() { return QUndoStack::isClean(); }

    Q_INVOKABLE void addVariant(VariantsList* list, const QString id) {
        push(new UndoCommand::AddVariant(list, id));
    }
    Q_INVOKABLE void removeVariant(VariantsList* list, int index) {
        push(new UndoCommand::RemoveVariant(list, index));
    }
    Q_INVOKABLE void addFlag(Variant* variant, const QString flag) {
        push(new UndoCommand::AddFlag(variant, flag));
    }
    Q_INVOKABLE void removeFlag(Variant* variant, const QString flag) {
        push(new UndoCommand::RemoveFlag(variant, flag));
    }
    Q_INVOKABLE void addInclude(IncludesList* list, const QString string) {
        push(new UndoCommand::AddInclude(list, string));
    }
    Q_INVOKABLE void removeInclude(IncludesList* list, const int index) {
        push(new UndoCommand::RemoveInclude(list, index));
    }
    Q_INVOKABLE void editText(QObject* target,  const QString property, const QString newText) {
        push(new UndoCommand::EditText(target, property, newText));
    }
    Q_INVOKABLE void setSymbol(Variant* variant, const QString keyname, const int level, const QString keysym) {
        push(new UndoCommand::SetSymbol(variant, keyname, level, keysym));
    }
    Q_INVOKABLE void moveElement(List* list, const int oldIndex, const int newIndex) {
        push(new UndoCommand::MoveElement(list, oldIndex, newIndex));
    }
};
