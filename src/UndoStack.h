#include <QList>
#include <QUndoStack>
#include <QtQml/qqmlregistration.h>
#include <qtmetamacros.h>

#include "UndoCommands.h"
#include "VariantsList.h"

class UndoStack : public QUndoStack {
    Q_OBJECT
    QML_ELEMENT
public:
    Q_INVOKABLE void clear() { QUndoStack::clear(); }

    Q_INVOKABLE void addVariant(VariantsList* list, QString id) { push(new AddVariant(list, id)); }
};
