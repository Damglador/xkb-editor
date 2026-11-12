#include <QList>
#include <QObject>
#include <QString>
#include <QtLogging>
#include <cstddef>
#include <fstream>
#include <iostream>
#include <peglib.h>
#include <string>

#include "Types/KeyProps.h"
#include "Types/Variant.h"
#include "macros.h"

#include "xkb.h"

using namespace std;
using namespace peg;

#define str QString::fromStdString
#define semvals peg::SemanticValues
#define tokenToString [](const semvals& vs) { return QString::fromStdString(vs.token_to_string()); }

const string grammar = {
#embed "xkb.peg"
};

string readFile(string filePath) {

    ifstream file(filePath);

    if (!file.is_open()) {
        cerr << "Failed to open: " << filePath << std::endl;
        return "";
    }

    string result;
    string line;
    while (getline(file, line)) {
        result += line;
        result += "\n";
    }

    return result;
}

KeyProps* parseKeyProps(const shared_ptr<Ast> ast, QObject* parent = nullptr) {
    auto props = new KeyProps(parent);
    const auto& nodes = ast->nodes;
    for (auto node : nodes) {
        if (node->name == "key_syms") {
            for (size_t i = 0; i < min(node->nodes.size(), (size_t)props->symbols().size()); i++) {
                auto symNode = node->nodes[i];
                switch (node->nodes[i]->choice) {
                case 2: // STRING choice
                    props->symbols()[i] = str(trim(symNode->token_to_string(), "\""));
                    break;
                default: // HEX or IDENT
                    props->symbols()[i] = str(symNode->token_to_string());
                    break;
                }
            }
        }
    }
    return props;
}

Variant* parseVariant(const shared_ptr<Ast> ast, QObject* parent = nullptr) {
    auto var = new Variant(parent);
    const auto& nodes = ast->nodes;
    for (auto node : nodes) {
        auto rule = node->name;
        if (rule == "FLAG") {
            var->addFlag(QString::fromStdString(node->token_to_string()));
        } else if (rule == "id") {
            var->setId(str(trim(node->token_to_string(), "\"")));
        } else if (rule == "name") {
            var->setName(str(trim(node->token_to_string(), "\"")));
        } else if (rule == "include") {
            const QString include = str(trim(node->token_to_string(), "\""));
            var->includes()->append(Include::fromString(include));
        } else if (rule == "key_type_default") {
            var->setKeytype(str(node->token_to_string()));
        } else if (rule == "key") {
            QString name = str(trim(node->nodes[0]->token_to_string(), "<>")); // KEYCODE
            var->keymap().insert(name, parseKeyProps(node->nodes[1]));
        }
    }

    return var;
}

void parseXkbSymbols(const shared_ptr<Ast> ast, QList<Variant*>* list, QObject* parent = nullptr) {
    for (auto node : ast->nodes) {
        if (node->name == "variant" && node->nodes.size() != 0)
            list->append(parseVariant(node, parent));
    }
}

QList<Variant*> variantsFromFile(QString filePath, QObject* parent) {
    QObject buffer;

    peg::parser parser(grammar);

    QList<Variant*> list;

    shared_ptr<Ast> ast;
    parser.enable_ast(true, false, { "key_prop", "statement" });
    const string content = readFile(filePath.toStdString());
    parser.parse(content, ast);

    qDebug().noquote() << ast_to_s(ast);

    parseXkbSymbols(ast, &list, parent);
    qDebug() << list[0]->id();
    qDebug() << list[0]->name();
    qDebug() << list[0]->flags();

    return list;
}
