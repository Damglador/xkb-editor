#include "Include.h"

Include::Include(QString path, QString variant, QObject* parent) : QObject(parent) {
    m_path = path;
    m_variant = variant;
    init();
}
Include::Include(QString path, QObject* parent) : QObject(parent) {
    m_path = path;
    init();
}

void Include::init() {
    connect(this, &Include::pathChanged, this, &Include::updateFile);
    connect(this, &Include::variantChanged, this, &Include::updateFile);
    updateFile();
}

// TODO: resolve variables in path of includes
// TODO: use regex or parse files
// because there can be newlines between xkb_symbols and variant name
void Include::updateFile() {
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

QString Include::toString() const {
    return m_variant.isEmpty() ? m_path : m_path + u"("_s + m_variant + u")"_s;
}

Include* Include::fromString(const QString string, QObject* parent) {
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
