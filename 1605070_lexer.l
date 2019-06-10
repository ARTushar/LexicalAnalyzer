%option noyywrap
%x comment
%{
    #include "1605070_SymbolTable.cpp"
    #include <cstdio>
    #include <cstdlib>
    #include <string>
    using namespace std;

    int line_count = 1;
    FILE *logout;
    FILE *tokenout;
    SymbolTable symbolTable(50);
    extern "C" int yylex();
    string current_comment = "";

    void strupr(char *str);
    void print_log(const char *type, const char *symbol);
    void filter_string(string& str);

%}

DIGIT [0-9]+

%%

 /* identifying keywords */

"if" |
"else" |
"for" |
"while" |
"do" |
"break" |
"int" |
"char" |
"float" |
"double" |
"void" |
"return" |
"switch" |
"case" |
"default" |
"continue" {
    string lexeme(yytext);
    strupr(yytext);
    fprintf(tokenout, "<%s> ", yytext);
    print_log(yytext, lexeme.c_str());
}


 /* identifying constants */

{DIGIT} {

    fprintf(tokenout, "<CONST_INT, %s> ", yytext);
    print_log("CONST_INT", yytext);
    if(symbolTable.insert(yytext, "CONST_INT"))
        symbolTable.print();
}

[0-9]*\.{DIGIT}([eE][-+]?{DIGIT})? |
{DIGIT}[eE][-+]?{DIGIT} {

    fprintf(tokenout, "<CONST_FLOAT, %s> ", yytext);
    print_log("CONST_FLOAT", yytext);
    if(symbolTable.insert(yytext, "CONST_FLOAT"))
        symbolTable.print();
}



\'.\' {
    string str = "";
    str += yytext[1];
    fprintf(tokenout, "<CONST_CHAR, %c> ", yytext[1]);
    print_log("CONST_CHAR", str.c_str());
    if(symbolTable.insert(str, "CONST_CHAR"))
        symbolTable.print();
}
\'(\\n|\\t|\\\\|\\\"|\\a|\\f|\\r|\\b|\\v|\\0)\' {
    string str(yytext);
    filter_string(str);
    fprintf(tokenout, "<CONST_CHAR, %s> ", str.c_str());
    print_log("CONST_CHAR", str.c_str());
    if(symbolTable.insert(str, "CONST_CHAR"))
        symbolTable.print();
}

 /* operators and punctuators */
[-+] {
    fprintf(tokenout, "<ADDOP, %s> ", yytext);
    print_log("ADDOP", yytext);
    if(symbolTable.insert(yytext, "ADDOP"))
        symbolTable.print();
}

[*/%] {
    fprintf(tokenout, "<MULOP, %s> ", yytext);
    print_log("MULOP", yytext);
    if(symbolTable.insert(yytext, "MULOP"))
        symbolTable.print();
}

\+\+|-- {
    fprintf(tokenout, "<INCOP, %s> ", yytext);
    print_log("INCOP", yytext);
    if(symbolTable.insert(yytext, "INCOP"))
        symbolTable.print();
}

\<=|\<|\>=|\>|==|!= {
    fprintf(tokenout, "<RELOP, %s> ", yytext);
    print_log("RELOP", yytext);
    if(symbolTable.insert(yytext, "RELOP"))
        symbolTable.print();
}

= {
    fprintf(tokenout, "<ASSIGNOP, %s> ", yytext);
    print_log("ASSIGNOP", yytext);
    if(symbolTable.insert(yytext, "ASSIGNOP"))
        symbolTable.print();
}

&&|\|\| {
    fprintf(tokenout, "<LOGICOP, %s> ", yytext);
    print_log("LOGICOP", yytext);
    if(symbolTable.insert(yytext, "LOGICOP"))
        symbolTable.print();
}

&|\||\^|<<|>> {
    fprintf(tokenout, "<BITOP, %s> ", yytext);
    print_log("BITOP", yytext);
    if(symbolTable.insert(yytext, "BITOP"))
        symbolTable.print();
}

! {
    fprintf(tokenout, "<NOT, !>");
    print_log("NOT", yytext);
    if(symbolTable.insert("!", "NOT"))
        symbolTable.print();
}

\) {
    fprintf(tokenout, "<RPAREN, )> ");
    print_log("RPAREN", yytext);
    if(symbolTable.insert(")", "RPAREN"))
        symbolTable.print();
}

\( {
    fprintf(tokenout, "<LPAREN, (> ");
    print_log("LPAREN", yytext);
    if(symbolTable.insert("(", "LPAREN"))
        symbolTable.print();
}

\{ {
    fprintf(tokenout, "<LCURL, {> ");
    print_log("LCURL", yytext);
    if(symbolTable.insert("{", "LCURL"))
        symbolTable.print();
}

\} {
    fprintf(tokenout, "<RCURL, }> ");
    print_log("RCURL", yytext);
    if(symbolTable.insert("}", "RCURL"))
        symbolTable.print();
}

\[ {
    fprintf(tokenout, "<LTHIRD, [> ");
    print_log("LTHIRD", yytext);
    if(symbolTable.insert("[", "LTHIRD"))
        symbolTable.print();
}

\] {
    fprintf(tokenout, "<RTHIRD, ]> ");
    print_log("RTHIRD", yytext);
    if(symbolTable.insert("]", "RTHIRD"))
        symbolTable.print();
}

, {
    fprintf(tokenout, "<COMMA, ,> ");
    print_log("COMMA", yytext);
    if(symbolTable.insert(",", "COMMA"))
        symbolTable.print();
}

; {
    fprintf(tokenout, "<SEMICOLON, ;> ");
    print_log("SEMICOLON", yytext);
    if(symbolTable.insert(";", "SEMICOLON"))
        symbolTable.print();
}

 /* Identifiers */

[a-zA-Z_][a-zA-Z_0-9]* {
    fprintf(tokenout, "<ID, %s> ", yytext);
    print_log("ID", yytext);
    if(symbolTable.insert(yytext, "ID"))
        symbolTable.print();
}

 /* strings */

(\"[^"\n]*\\(\n[^"\n]*\\)*\n[^"\n]*\")|(\"[^"\n]*\") {
    string str(yytext);
    filter_string(str);
    fprintf(tokenout, "<STRING, %s> ", str.c_str());
    print_log("STRING", str.c_str());
    if(symbolTable.insert(str, "STRING"))
        symbolTable.print();
}

 /* comment */
\/\* { BEGIN comment;}
<comment>\*\/ { 
    print_log("COMMENT", current_comment.c_str());
    current_comment = "";
    BEGIN INITIAL;
}
<comment>[\n] { current_comment += yytext; line_count++; }
<comment>([^*\n])+|. { current_comment += yytext; }

\/\/.*\\\n([^\n]+\\\n)*[^\n]*\n|\/\/.*\n { 
    string str(yytext);
    str.erase(0,2);
    str.pop_back();
    print_log("COMMENT", str.c_str());
    line_count++; 
}

 /*line count */
[\n] { line_count++; }

  /* white space */
[ \t]+ { }


%%

int main(int argc, char *argv[]) {
    
    if(argc != 2) {
        printf("Please input the fileName\n");
        return 1;
    }

    FILE *finp = fopen(argv[1], "r");

    if(!finp) {
        printf("Cannot open the input file\n");
        return 1;
    }

    logout = fopen("log.txt","w");
	tokenout = fopen("token.txt","w");

    yyin = finp;
	yylex();
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);

	return 0;
}

void print_log(const char *type, const char *symbol){
    fprintf(logout, "Line no. %d: Token <%s> Lexeme %s found\n", line_count, type, symbol);
}

void strupr(char *str) {
    for(int i = 0; i < strlen(str); i++){
        str[i] = toupper(str[i]);
    }
}

void filter_string(string& str) {
    str.pop_back();
    str.erase(0,1);
    int i = 0;
    for(; i < str.size()-1; i++) {
        if(str[i] == '\\'){
            if(str[i+1] == 'n') {
                str.replace(i, 2, 1,'\n');
                i++;
            } else if(str[i+1] == 'r'){
                str.replace(i, 2, 1, '\r');
                i++;
            } else if(str[i+1] == 't'){
                str.replace(i, 2, 1, '\t');
                i++;
            } else if(str[i+1] == '\\'){
                str.replace(i, 2, 1, '\\');
                i++;
            } else if(str[i+1] == '"'){
                str.replace(i, 2, 1, '"');
                i++;
            } else if(str[i+1] == 'a'){
                str.replace(i, 2, 1, '\a');
                i++;
            } else if(str[i+1] == 'f'){
                str.replace(i, 2, 1, '\f');
            } else if(str[i+1] == 'v'){
                str.replace(i, 2, 1, '\v');
                i++;
            } else if(str[i+1] == 'b'){
                str.replace(i, 2, 1, '\b');
                i++;
            } else if(str[i+1] == '0'){
                str.replace(i, 2, 1, '\0');
                i++;
            } else if(str[i+1] == '\n'){
                line_count++;
                str.replace(i, 2, "");
            }
        }
    }
}