#pragma once

#include <QFile>
#include <QObject>
#include <QRegularExpression>
#include <qtmetamacros.h>
#include <xkbcommon/xkbcommon.h>

#include "getchar.h"
#include "macros.h"

using namespace Qt::Literals::StringLiterals;

class Include : public QObject {
    Q_OBJECT

    // clang-format off
    Q_PROPERTY(QString path    READ path    WRITE setPath    NOTIFY pathChanged   )
    Q_PROPERTY(QString variant READ variant WRITE setVariant NOTIFY variantChanged)
    Q_PROPERTY(QString file    READ file                     NOTIFY fileChanged   )

    PROP(QString, path,      setPath     )
    PROP(QString, variant,   setVariant  )
    PROP(QString, file,      setFile     )
    // clang-format on
public:
    Include(QString path, QString variant, QObject* parent = nullptr);
    Include(QString path, QObject* parent = nullptr);
    void init();

    // TODO: resolve variables in path of includes
    // TODO: use regex or parse files
    // because there can be newlines between xkb_symbols and variant name
    Q_SLOT void updateFile();

    Q_INVOKABLE QString toString() const;

    static Include* fromString(const QString string, QObject* parent = nullptr);
};
