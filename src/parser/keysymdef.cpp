#include <fstream>
#include <iostream>
#include <peglib.h>
#include <QString>

using namespace std;

#define semvals peg::SemanticValues

struct Item {
    QString name;
    QString keysym;
    QString character;
    QString comment;
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

int main() {
    string filePath = "/home/damglador/projects/xkb-editor/src/parser/keysymdef.peg";

    string grammar = readFile(filePath);
    cout << grammar;
    peg::parser parser(grammar);

    parser["COPYRIGHT"] = [](const semvals &sv) {
        return Item { .comment = QString::fromUtf8(sv.token_to_string()) };
    };

    parser["start"] = [](const semvals &sv) {
        sv.transform<Item>();
    };


    // parser.parse(readFile("/usr/include/X11/keysymdef.h"));
}
