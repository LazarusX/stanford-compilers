/*
 *  The scanner definition for COOL.
 */

import java_cup.runtime.Symbol;

%%

%{

/*  Stuff enclosed in %{ %} is copied verbatim to the lexer class
 *  definition, all the extra variables/functions you want to use in the
 *  lexer actions should go here.  Don't remove or modify anything that
 *  was there initially.  */

    // Max size of string constants
    static int MAX_STR_CONST = 1025;

    // For assembling string constants
    StringBuffer string_buf = new StringBuffer();

    int get_curr_lineno() {
	return yyline + 1;
    }

    private AbstractSymbol filename;

    void set_filename(String fname) {
	filename = AbstractTable.stringtable.addString(fname);
    }

    AbstractSymbol curr_filename() {
	return filename;
    }

    private int blockCommentCount = 0;

    private boolean foundNullChar = false;
%}

%init{

/*  Stuff enclosed in %init{ %init} is copied verbatim to the lexer
 *  class constructor, all the extra initialization you want to do should
 *  go here.  Don't remove or modify anything that was there initially. */

    // empty for now
%init}

%eofval{

/*  Stuff enclosed in %eofval{ %eofval} specifies java code that is
 *  executed when end-of-file is reached.  If you use multiple lexical
 *  states and want to do something special if an EOF is encountered in
 *  one of those states, place your code in the switch statement.
 *  Ultimately, you should return the EOF symbol, or your lexer won't
 *  work.  */

    switch(yy_lexical_state) {
        case YYINITIAL:
            /* nothing special to do in the initial state */
            break;
        case BLOCK_COMMENT:
            yybegin(YYINITIAL);
            return new Symbol(TokenConstants.ERROR, "EOF in comment");
        case STRING_CONSTANT:
            yybegin(YYINITIAL);
            return new Symbol(TokenConstants.ERROR, "EOF in string constant");
    }
    return new Symbol(TokenConstants.EOF);
%eofval}

DIGIT = [0-9]
LETTER = [A-Za-z]
WHITE_SPACE = [\n\ \t\b\f\r\v\013]
NEW_LINE = \n|\r

CLASS = [Cc][Ll][Aa][Ss][Ss]
IF = [Ii][Ff]
ELSE = [Ee][Ll][Ss][Ee]
FI = [Ff][Ii]
IN = [Ii][Nn]
INHERITS = [Ii][Nn][Hh][Ee][Rr][Ii][Tt][Ss]
LET = [Ll][Ee][Tt]
LOOP = [Ll][Oo][Oo][Pp]
POOL = [Pp][Oo][Oo][Ll]
THEN = [Tt][Hh][Ee][Nn]
WHILE = [Ww][Hh][Ii][Ll][Ee]
CASE = [Cc][Aa][Ss][Ee]
ESAC = [Ee][Ss][Aa][Cc]
OF = [Oo][Ff]
NEW = [Nn][Ee][Ww]
ISVOID = [Ii][Ss][Vv][Oo][Ii][Dd]
NOT = [Nn][Oo][Tt]
TRUE = t[Rr][Uu][Ee]
FALSE = f[Aa][Ll][Ss][Ee]

%state BLOCK_COMMENT, STRING_CONSTANT
%line

%class CoolLexer
%cup

%%

<YYINITIAL> --.* {

}

<YYINITIAL> "(*" {
    yybegin(BLOCK_COMMENT);
    blockCommentCount++;
}

<BLOCK_COMMENT> "(*" {
    blockCommentCount++;
}

<BLOCK_COMMENT> "*)" {
    blockCommentCount--;
    if (blockCommentCount == 0) {
        yybegin(YYINITIAL);
    }
}

<YYINITIAL> "*)" {
    return new Symbol(TokenConstants.ERROR, "Unmatched *)");
}

<BLOCK_COMMENT> .|{NEW_LINE} {
}

<YYINITIAL> {WHITE_SPACE} {
    
}

<YYINITIAL> \" {
    string_buf.setLength(0);
    foundNullChar = false;
    yybegin(STRING_CONSTANT);
}

<STRING_CONSTANT> \x00 {
    foundNullChar = true;
}

<STRING_CONSTANT> \\b {
    string_buf.append("\b");
}

<STRING_CONSTANT> \\f {
    string_buf.append("\f");
}

<STRING_CONSTANT> \\t {
    string_buf.append("\t");
}

<STRING_CONSTANT> \\n {
    string_buf.append("\n");
}

<STRING_CONSTANT> \\\n {
    string_buf.append("\n");
}

<STRING_CONSTANT> \\\" {
    string_buf.append("\"");
}

<STRING_CONSTANT> \\\\ {
    string_buf.append("\\");
}

<STRING_CONSTANT> \\ {

}

<STRING_CONSTANT> [^\"\0\n\\]+ {
    string_buf.append(yytext());
}

<STRING_CONSTANT> \n {
    string_buf.setLength(0);
    foundNullChar = false;
    yybegin(YYINITIAL);
    return new Symbol(TokenConstants.ERROR, "Unterminated string constant");
}

<STRING_CONSTANT> \" {
    yybegin(YYINITIAL);
    String s = string_buf.toString();
    if (foundNullChar) {
        return new Symbol(TokenConstants.ERROR, "String contains null character");
    } else if (s.length() >= MAX_STR_CONST) {
        return new Symbol(TokenConstants.ERROR, "String constant too long");
    } else {
        return new Symbol(TokenConstants.STR_CONST, 
            new StringSymbol(s, s.length(), s.hashCode()));
    }
}

<YYINITIAL> {CLASS} {
    return new Symbol(TokenConstants.CLASS);
}

<YYINITIAL> {IF} {
    return new Symbol(TokenConstants.IF);
}

<YYINITIAL> {ELSE} {
    return new Symbol(TokenConstants.ELSE);
}

<YYINITIAL> {FI} {
    return new Symbol(TokenConstants.FI);
}

<YYINITIAL> {IN} {
    return new Symbol(TokenConstants.IN);
}

<YYINITIAL> {INHERITS} {
    return new Symbol(TokenConstants.INHERITS);
}

<YYINITIAL> {LET} {
    return new Symbol(TokenConstants.LET);
}

<YYINITIAL> {LOOP} {
    return new Symbol(TokenConstants.LOOP);
}

<YYINITIAL> {POOL} {
    return new Symbol(TokenConstants.POOL);
}

<YYINITIAL> {THEN} {
    return new Symbol(TokenConstants.THEN);
}

<YYINITIAL> {WHILE} {
    return new Symbol(TokenConstants.WHILE);
}

<YYINITIAL> {CASE} {
    return new Symbol(TokenConstants.CASE);
}

<YYINITIAL> {ESAC} {
    return new Symbol(TokenConstants.ESAC);
}

<YYINITIAL> {OF} {
    return new Symbol(TokenConstants.OF);
}

<YYINITIAL> {NEW} {
    return new Symbol(TokenConstants.NEW);
}

<YYINITIAL> {ISVOID} {
    return new Symbol(TokenConstants.ISVOID);
}

<YYINITIAL> "<-" {
    return new Symbol(TokenConstants.ASSIGN);
}

<YYINITIAL> {NOT} {
    return new Symbol(TokenConstants.NOT);
}

<YYINITIAL> "+" {
    return new Symbol(TokenConstants.PLUS);
}

<YYINITIAL> "-" {
    return new Symbol(TokenConstants.MINUS);
}

<YYINITIAL> "*" {
    return new Symbol(TokenConstants.MULT);
}

<YYINITIAL> "/" {
    return new Symbol(TokenConstants.DIV);
}

<YYINITIAL> "=" {
    return new Symbol(TokenConstants.EQ);
}

<YYINITIAL> "<" {
    return new Symbol(TokenConstants.LT);
}

<YYINITIAL> "<=" {
    return new Symbol(TokenConstants.LE);
}

<YYINITIAL> "." {
    return new Symbol(TokenConstants.DOT);
}

<YYINITIAL> "~" {
    return new Symbol(TokenConstants.NEG);
}

<YYINITIAL> "," {
    return new Symbol(TokenConstants.COMMA);
}

<YYINITIAL> ":" {
    return new Symbol(TokenConstants.COLON);
}

<YYINITIAL> ";" {
    return new Symbol(TokenConstants.SEMI);
}

<YYINITIAL> "(" {
    return new Symbol(TokenConstants.LPAREN);
}

<YYINITIAL> ")" {
    return new Symbol(TokenConstants.RPAREN);
}

<YYINITIAL> "{" {
    return new Symbol(TokenConstants.LBRACE);
}

<YYINITIAL> "}" {
    return new Symbol(TokenConstants.RBRACE);
}

<YYINITIAL> "@" {
    return new Symbol(TokenConstants.AT);
}

<YYINITIAL> {TRUE} {
    return new Symbol(TokenConstants.BOOL_CONST, "true");
}

<YYINITIAL> {FALSE} {
    return new Symbol(TokenConstants.BOOL_CONST, "false");
}

<YYINITIAL> {DIGIT}+ {
    return new Symbol(TokenConstants.INT_CONST, 
        new IntSymbol(yytext(), yytext().length(), yytext().hashCode()));
}

<YYINITIAL> [A-Z]({LETTER}|{DIGIT}|_)* {
    return new Symbol(TokenConstants.TYPEID, 
        new IdSymbol(yytext(), yytext().length(), yytext().hashCode()));
}

<YYINITIAL> [a-z]({LETTER}|{DIGIT}|_)* {
    return new Symbol(TokenConstants.OBJECTID, 
        new IdSymbol(yytext(), yytext().length(), yytext().hashCode()));
}

<YYINITIAL> "=>" {
    /* Sample lexical rule for "=>" arrow.
    Further lexical rules should be defined
    here, after the last %% separator */
    return new Symbol(TokenConstants.DARROW);
}

. {
    /* This rule should be the very last
    in your lexical specification and
    will match match everything not
    matched by other lexical rules. */
    return new Symbol(TokenConstants.ERROR, yytext());
}
