#include <QUndoStack>
#include <QtQml/qqmlregistration.h>
#include <qlist.h>
#include <qtmetamacros.h>

#include "Variant.h"
#include "VariantsList.h"

class UndoStack : public QUndoStack {
    Q_OBJECT
    QML_ELEMENT
public:
    void addVariant(VariantsList, QString id) {

    }
};
