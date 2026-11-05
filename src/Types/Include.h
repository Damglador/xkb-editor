#pragma once

#include <qobject.h>
#include <qregularexpression.h>
#include <qtmetamacros.h>

#include "macros.h"

using namespace Qt::Literals::StringLiterals;

class Include : public QObject {
    Q_OBJECT
    PROP(QString, path, setPath)
    PROP(QString, variant, setVariant)
public:
    Include(QString path, QString variant, QObject *parent = nullptr) : QObject(parent) {
        m_path = path;
        m_variant = variant;
    }
    Include(QString path, QObject *parent = nullptr) : QObject(parent) {
        m_path = path;
    }
    // TODO: from string and to string
    QString toString() {
        return m_variant.isEmpty() ? m_path : m_path + u"("_s + m_variant + u")"_s;
    }
    static Include *fromString(const QString string) {
        if (string.isEmpty())
             return nullptr;

        QRegularExpression re(uR"((.*)\((.*)\)$)"_s);
        QRegularExpressionMatch match = re.match(string);
        if (match.hasMatch()) {
            return new Include(match.captured(1), match.captured(2));
        } else {
            return new Include(string);
        }
    }
};
