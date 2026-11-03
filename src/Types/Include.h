#include <qobject.h>
#include <qtmetamacros.h>

class Include : public QObject {
    Q_OBJECT
private:
    QString m_path;
    QString m_variant;
public:
    QString path() { return m_path; }
    QString variant() { return m_variant; }

    void setPath(QString value) {
        if (m_path == value)
            return;
        m_path = value;
        Q_EMIT pathChanged();
    }
    void setVariant(QString value) {
        if (m_variant == value)
            return;
        m_variant = value;
        Q_EMIT variantChanged();
    }
    // TODO: from string and to string
Q_SIGNALS:
    void pathChanged();
    void variantChanged();
};
