//
// Created by tushar on 5/9/19.
//

#ifndef SYMBOL_TABLE_SYMBOLTABLE_H
#define SYMBOL_TABLE_SYMBOLTABLE_H

#include "1605070_ScopeTable.cpp"
#include <iostream>
using namespace std;

class SymbolTable {
private:
    ScopeTable *currentScopeTable;
    int bucketSize;
public:
    SymbolTable(int bucketSize);
    void enterScope();
    void exitScope();
    bool insert(const string& name, const string& type);
    bool remove(const string& name);
    SymbolInfo* lookUp(const string& name);
    void print();
    void printAll();

    virtual ~SymbolTable();

};


#endif //SYMBOL_TABLE_SYMBOLTABLE_H