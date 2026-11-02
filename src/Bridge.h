#pragma once

#include <qobject.h>
#include <qqmlintegration.h>
class Bridge : public QObject {
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT
public:
    explicit Bridge(QObject* parent = nullptr);
    ~Bridge();
};
