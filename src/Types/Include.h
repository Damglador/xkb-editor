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
    Include(QString path, QString variant, QObject* parent = nullptr) : QObject(parent) {
        m_path = path;
        m_variant = variant;
        connect(this, &Include::pathChanged, this, &Include::updateFile);
        connect(this, &Include::variantChanged, this, &Include::updateFile);
        updateFile();
    }
    Include(QString path, QObject* parent = nullptr) : QObject(parent) {
        Include(path, QString(), parent);
    }

    // TODO: resolve variables in path of includes
    // TODO: use regex or parse files
    // because there can be newlines between xkb_symbols and variant name
    Q_SLOT void updateFile() {
        const char* path = NULL;

        for (uint i = 0; i < xkb_context_num_include_paths(xkb_context_default); i++) {
            path = xkb_context_include_path_get(xkb_context_default, i);
            if (path == NULL)
                break;
            QFile file(QString::fromLocal8Bit(path) + u"/symbols/"_s + m_path);
            if (!file.exists())
                continue;
            if (m_variant.isEmpty()) {
                setFile(file.fileName());
                return;
            } else {
                if (!file.open(QFile::ReadOnly | QFile::Text))
                    break;
                QTextStream stream(&file);
                QString line;
                do {
                    line = stream.readLine();
                    if (line.contains(u"xkb_symbols \"%1\""_s.arg(m_variant))) {
                        setFile(file.fileName());
                        return;
                    }
                } while (!line.isNull());
            }
        }
        setFile(QString());
    }

    Q_INVOKABLE QString toString() const {
        return m_variant.isEmpty() ? m_path : m_path + u"("_s + m_variant + u")"_s;
    }

    static Include* fromString(const QString string, QObject* parent = nullptr) {
        if (string.isEmpty())
            return nullptr;

        QRegularExpression re(uR"((.*)\((.*)\)$)"_s);
        QRegularExpressionMatch match = re.match(string);
        if (match.hasMatch()) {
            return new Include(match.captured(1), match.captured(2), parent);
        } else {
            return new Include(string, parent);
        }
    }
};
