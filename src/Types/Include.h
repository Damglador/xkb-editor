#pragma once

#include <qobject.h>
#include <qregularexpression.h>
#include <qtmetamacros.h>

using namespace Qt::Literals::StringLiterals;

class Include : public QObject {
    Q_OBJECT
private:
    QString m_path;
    QString m_variant;
public:
    Include(QString path, QString variant, QObject *parent = nullptr) : QObject(parent) {
        m_path = path;
        m_variant = variant;
    }
    Include(QString path, QObject *parent = nullptr) : QObject(parent) {
        m_path = path;
    }
    QString path() { return m_path; }
    QString variant() { return m_variant; }

    void setPath(const QString value) {
        if (m_path == value)
            return;
        m_path = value;
        Q_EMIT pathChanged();
    }
    void setVariant(const QString value) {
        if (m_variant == value)
            return;
        m_variant = value;
        Q_EMIT variantChanged();
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
Q_SIGNALS:
    void pathChanged();
    void variantChanged();
};
