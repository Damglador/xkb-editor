#include <any>
#include <fstream>
#include <iostream>
#include <peglib.h>
#include <string>

#include "keysymdef_parser.h"

using namespace std;

#define semvals peg::SemanticValues
#define tokenToString [](const semvals& vs) { return trim(vs.token_to_string()); }

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

// https://stackoverflow.com/questions/1798112/removing-leading-and-trailing-spaces-from-a-string
std::string trim(const std::string& str)
{
    std::string ignored = " \t\n\r*/";
    const auto strBegin = str.find_first_not_of(ignored);
    if (strBegin == std::string::npos)
        return ""; // no content

    const auto strEnd = str.find_last_not_of(ignored);
    const auto strRange = strEnd - strBegin + 1;

    return str.substr(strBegin, strRange);
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

    parser["COPYRIGHT"] = [](const semvals& vs) {
        // Don't fold
        return Item{ {}, {}, trim(vs.token_to_string()) };
    };

    // TODO: trim spaces and * on every line
    parser["DOC"] = [](const semvals &vs) {
        // Don't fold
        return Item{ {}, {}, trim(vs.token_to_string()) };
    };

    parser["KEYSYMNAME"] = tokenToString;
    parser["HEX"] = tokenToString;
    parser["DESC"] = tokenToString;

    parser["keysym"] = [](const semvals& vs) {
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

    parser["start"] = [](const semvals& sv) { return sv.transform<Item>(); };

    parser.parse(readFile(filePath), items);

    return items;
}

#ifdef TEST
int main() {
    cout << grammar;
    cout << itemsToString(tableFromFile("/usr/include/X11/keysymdef.h"));
}
#endif
