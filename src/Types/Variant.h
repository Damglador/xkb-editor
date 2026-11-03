#include <qcontainerfwd.h>
#include <qflags.h>
#include <qhashfunctions.h>
#include <qlist.h>
#include <qmetaobject.h>
#include <qqmlintegration.h>
#include <qobject.h>
#include <qtmetamacros.h>
#include <qurl.h>

#include "Include.h"
#include "Enums.h"

#define s QStringLiteral

#define PROP(type, name, setter)                        \
public:                                                 \
    type name() const { return m_##name; }              \
    void setter(const type &value) {                    \
        if (m_##name == value) return;                  \
        m_##name = value;                               \
        Q_EMIT name##Changed();                         \
    }                                                   \
private:                                                \
    type m_##name;                                      \

class Variant : public QObject {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString id               READ id         WRITE setId         NOTIFY idChanged)
    Q_PROPERTY(QString name             READ name       WRITE setName       NOTIFY nameChanged)
    Q_PROPERTY(QStringList flags        READ flags                          NOTIFY flagsChanged)
    Q_PROPERTY(QString keymap           READ keymap     WRITE setKeymap     NOTIFY keymapChanged)
    Q_PROPERTY(QList<Include> includes  READ includes                       NOTIFY includesChanged)
    Q_PROPERTY(QString keytype          READ keytype    WRITE setKeytype    NOTIFY keytypeChanged)
    Q_PROPERTY(QString source           READ source     WRITE setSource     NOTIFY sourceChanged)

    PROP(QString, id,       setId)
    PROP(QString, name,     setName)
    Enums::Flags m_flags;
    int m_keymap; // TODO: come up with a proper type
    QList<Include> m_includes;
    PROP(QString, keytype,  setKeytype)
    PROP(QString, source,   setSource)
public:
    explicit Variant(QObject* parent = nullptr) : QObject(parent) {}

    void addFlag(QString name) {
        auto meta = QMetaEnum::fromType<Enums::Flag>();
        m_flags |= static_cast<Enums::Flag>(meta.keyToValue(name.toUtf8().data()));
        Q_EMIT flagsChanged();
    }
    void removeFlag(QString name) {
        auto meta = QMetaEnum::fromType<Enums::Flag>();
        m_flags &= ~static_cast<Enums::Flag>(meta.keyToValue(name.toUtf8().data()));
        Q_EMIT flagsChanged();
    }
    QStringList flags() {
        QStringList names;
        return names;
    }

Q_SIGNALS:
    void idChanged();
    void nameChanged();
    void flagsChanged();
    void keymapChanged();
    void includesChanged();
    void keytypeChanged();
    void sourceChanged();
};
