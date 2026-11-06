#include "Variant.h"
#include <QUndoCommand>
#include <qobject.h>
#include <qrangemodel.h>

using namespace Qt::Literals::StringLiterals;

class AddVariant : public QUndoCommand {
    QRangeModel* variants;
    const QString id;
    const int index;
    AddVariant(QRangeModel* _variants, const QString _id)
        : variants(_variants), id(_id), index(_variants->rowCount()) { setText(u"Add %1"_s.arg(id)); };
    void undo() override {
        variants->removeRows(index, 1);
    }
    void redo() override {
        if (!variants->insertRows(index, 1))
            return;
        auto variant = new Variant();
        variant->setId(id);
        variants[index] = variant;
    }
};
