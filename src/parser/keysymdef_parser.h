#include <string>
#include <vector>

using namespace std;

struct Item {
    string name;
    string keysym;
    string comment;
};

string itemsToString(vector<Item>);
vector<Item> tableFromFile(string filePath);
