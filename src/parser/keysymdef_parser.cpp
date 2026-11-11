#include <any>
#include <fstream>
#include <iostream>
#include <peglib.h>
#include <string>

#include "keysymdef_parser.h"

using namespace std;

#define semvals peg::SemanticValues
#define tokenToString [](const semvals &vs) { return vs.token_to_string(); }

const string grammar = {
#embed "keysymdef.peg"
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

string itemsToString(vector<Item> items) {
    string result;
    for (Item item : items) {
        result += item.name + "\t" + item.keysym + "\t" + item.comment + "\n";
    }
    return result;
}

vector<Item> tableFromFile(string filePath) {
    vector<Item> items;
    peg::parser parser(grammar);

    parser["COPYRIGHT"] = [](const semvals &vs) {
        // Don't fold
        return Item{ {}, {}, vs.token_to_string() };
    };
    parser["DOC"] = [](const semvals &vs) {
        // Don't fold
        return Item{ {}, {}, vs.token_to_string() };
    };

    parser["KEYSYMNAME"] = tokenToString;
    parser["HEX"] = tokenToString;
    parser["DESC"] = tokenToString;

    parser["keysym"] = [](const semvals &vs) {
        Item item{
            any_cast<string>(vs[0]),
            any_cast<string>(vs[1]),
            {},
        };
        if (vs.size() == 3) {
            item.comment = any_cast<string>(vs[2]);
        }
        return item;
    };

    parser["start"] = [](const semvals &sv) { return sv.transform<Item>(); };

    parser.parse(readFile(filePath), items);

    return items;
}

#ifdef TEST
int main() {
    cout << grammar;
    cout << itemsToString(tableFromFile("/usr/include/X11/keysymdef.h"));
}
#endif
