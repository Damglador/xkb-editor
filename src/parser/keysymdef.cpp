#include <any>
#include <fstream>
#include <iostream>
#include <peglib.h>
#include <string>

using namespace std;

#define semvals peg::SemanticValues
#define tokenToString [](const semvals &vs) { return vs.token_to_string(); }

const string grammar = {
#embed "keysymdef.peg"
};

struct Item {
    string name;
    string keysym;
    string comment;
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

void printItems(vector<Item> items) {
    for (Item item : items) {
        cout << item.name << "\t" << item.keysym << "\t" << item.comment << endl;
    }
    return;
}

int main() {
    cout << grammar;
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

    vector<Item> items;
    parser["start"] = [](const semvals &sv) { return sv.transform<Item>(); };

    parser.parse(readFile("/usr/include/X11/keysymdef.h"), items);
    printItems(items);
}
