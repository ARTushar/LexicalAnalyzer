#include <iostream>
#include "1605070_SymbolTable.cpp"

using namespace std;

int main() {
    freopen("input.txt", "r", stdin);
    //freopen("output.txt", "w", stdout);
    int bucket;
    cin >> bucket;
    SymbolTable table(bucket);
    char operation = 0, which;
    string name;
    string type;
    while(cin >> operation){
        switch(operation){
            case 'I':{
                cin >> name >> type;
                table.insert(name, type);
                break;
            }
            case 'L':{
                cin >> name;
                table.lookUp(name);
                break;
            }
            case 'D':{
                cin >> name;
                table.remove(name);
                break;
            }
            case 'P':{
                cin >> which;
                if(which == 'A'){
                    table.printAll();
                } else if(which == 'C') table.print();
                else break;
                break;
            }
            case 'S':{
                table.enterScope();
                break;
            }
            case 'E':{
                table.exitScope();
                break;
            }
            default:
                continue;
        }
    }


    return 0;
}
