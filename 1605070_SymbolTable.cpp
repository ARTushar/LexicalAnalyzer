//
// Created by tushar on 5/9/19.
//

#include "1605070_SymbolTable.h"

SymbolTable::SymbolTable(int bucket, FILE* log) : bucketSize(bucket){
    logout = log;
    currentScopeTable = new ScopeTable(bucketSize, log);
}

SymbolTable::~SymbolTable() {
    delete currentScopeTable;

}

void SymbolTable::enterScope() {
    auto *newScope = new ScopeTable(bucketSize, logout);
    newScope->setParentScope(currentScopeTable);
    currentScopeTable = newScope;
    cout << "New ScopeTable with id " << newScope->getId() << " created" << endl << endl;
}

void SymbolTable::exitScope() {
    ScopeTable* parent = currentScopeTable->getParentScope();
    cout << "ScopeTable with id " << currentScopeTable->getId() << " removed" << endl << endl;
    delete currentScopeTable;
    currentScopeTable = parent;
}

bool SymbolTable::insert(const string& name, const string& type) {
    return currentScopeTable->insert(name, type);
}

bool SymbolTable::remove(const string& name) {
    return currentScopeTable->deleteSymbol(name);
}

SymbolInfo *SymbolTable::lookUp(const string& name) {
    ScopeTable *current = currentScopeTable;
    SymbolInfo* lookedSymbol = current->lookUp(name);
    while(current->getParentScope() != nullptr && lookedSymbol == nullptr){
        lookedSymbol = current->getParentScope()->lookUp(name);
        current = current->getParentScope();
    }
    return lookedSymbol;

}

void SymbolTable::print() {
    currentScopeTable->print();
}

void SymbolTable::printAll() {
    ScopeTable *current = currentScopeTable;
    current->print();
    while(current->getParentScope() != nullptr){
        current = current->getParentScope();
        current->print();
    }
}
