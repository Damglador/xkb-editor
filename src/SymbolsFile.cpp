#include <KLocalization>
#include <QUrl>

#include "parser/xkb.h"
#include "SymbolsFile.h"

using namespace Qt::Literals::StringLiterals;

SymbolsFile::SymbolsFile(QObject* parent) : QObject(parent) {
    connect(this, &SymbolsFile::variantIndexChanged, this, &SymbolsFile::updateVariant);
    connect(&m_variants, &VariantsList::rowsRemoved, this, &SymbolsFile::updateVariant);
    connect(&m_variants, &VariantsList::rowsInserted, this, &SymbolsFile::updateVariant);
    connect(&m_variants, &VariantsList::modelReset, this, &SymbolsFile::updateVariant);
};

void SymbolsFile::updateVariant() {
    if (0 <= m_variantIndex && m_variantIndex < m_variants.rowCount()) {
        m_variant = m_variants.get(m_variantIndex);
    } else {
        m_variant = nullptr;
    }
    Q_EMIT variantChanged();
}

bool SymbolsFile::load(QString filePath) {
    // TODO: check if a file is a binary and catch parse failures
    QString path = QUrl(filePath).path();

    QList<Variant*> variants;

    int result = variantsFromFile(path, &variants, &m_variants);

    switch (result) {
    case ERROR_PARSING: Q_EMIT error(i18n("Failed to parse file.")); return false;
    case ERROR_OPEN_FILE: Q_EMIT error(i18n("Failed to open file.")); return false;
    case ERROR_EMPTY_FILE: Q_EMIT error(i18n("Empty file.")); return false;
    }

    m_variants.setItems(variants);
    setVariantIndex(0);
    setPath(path);
    fileLoaded();
    return true;
}

bool SymbolsFile::write(QString filePath) {
    QFile file(QUrl(filePath).path());
    if (!file.open(QFile::WriteOnly | QFile::Text)) {
        Q_EMIT error(i18n("Failed to write %1.", file.fileName()));
        return false;
    }
    QTextStream stream(&file);
    stream << toXkb();
    file.close();

    return true;
}

void SymbolsFile::clear() {
    setPath(u""_s);
    setVariantIndex(0);
    m_variants.clear();
    Q_EMIT fileLoaded();
}

QString SymbolsFile::toXkb() {
    QString result;
    QStringList variants;
    for (int i = 0; i < m_variants.length(); i++) {
        variants.append(m_variants.get(i)->toXkb());
    }
    return variants.join(u"\n"_s);
}
