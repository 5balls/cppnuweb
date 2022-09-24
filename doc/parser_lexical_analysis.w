% Copyright 2022 Florian Pesth
%
% This file is part of cppnuweb.
%
% cppnuweb is free software: you can redistribute it and/or modify
% it under the terms of the GNU Affero General Public License as
% published by the Free Software Foundation version 3 of the
% License.
%
% cppnuweb is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Affero General Public License for more details.
%
% You should have received a copy of the GNU Affero General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

\chapter{Nuweb Parser}

We try to use the Flex and Bison programs to create our parser.

\section{Lexical analysis}
\codebisonflex
@O ../src/nuweb.l
@{
%{
#include <iostream>
#include "../../src/helplexer.h"
#include "parser.hpp"
#include "../../src/file.h"

#define DDEBUG_LEXER(X) std::cout << X << "[" << filenameStack.back() << ":" << lineno() << "," << columno() << "](" << str() << "){" << file::byName(filenameStack.back())->utf8() << "}"; std::cout.flush();
#define DEBUG_LEXER(X) std::cout << X << "[" << filenameStack.back() << ":" << lineno() << "," << columno() << "](" << str() << ")"; std::cout.flush();
#define TOKEN(X) yylvalue->m_filePosition = new filePosition(filenameStack.back(),lineno(),columno(),lineno_end(),columno_end()); return yy::parser::token::yytokentype::X;
#define DTOKEN(X) DEBUG_LEXER(#X) yylvalue->m_filePosition = new filePosition(filenameStack.back(),lineno(),columno(),lineno_end(),columno_end()); return yy::parser::token::yytokentype::X;
#define STRINGTOKEN(X) yylvalue->m_stringValue = new filePositionWithString(std::string(filenameStack.back()),lineno(),columno(),lineno_end(),columno_end(),str()); return yy::parser::token::yytokentype::X;
#define DSTRINGTOKEN(X) DEBUG_LEXER(#X) yylvalue->m_stringValue = new filePositionWithString(std::string(filenameStack.back()),lineno(),columno(),lineno_end(),columno_end(),str()); return yy::parser::token::yytokentype::X;
#define DDSTRINGTOKEN(X) DDEBUG_LEXER(#X) yylvalue->m_stringValue = new filePositionWithString(std::string(filenameStack.back()),lineno(),columno(),lineno_end(),columno_end(),str()); return yy::parser::token::yytokentype::X;
#define INTTOKEN(X,Y) yylvalue->m_intValue = new filePositionWithInt(std::string(filenameStack.back()),lineno(),columno(),lineno_end(),columno_end(),Y); return yy::parser::token::yytokentype::X;
#define DINTTOKEN(X,Y) DEBUG_LEXER(#X) INTTOKEN(X,Y)
%}

%option c++
%option noyywrap
%option yylineno
%option yyclass="helpLexer"

%x scrapContents
%x outputFileHeader
%x fragmentHeader
%x fragmentExpansion

%%
 /* rules */
<INITIAL>@@i[ ][^\n]+ { include_file(); return yy::parser::token::yytokentype::AT_I; }
<INITIAL,scrapContents,fragmentHeader>@@@@ { STRINGTOKEN(AT_AT) }
<outputFileHeader>-d { DTOKEN(MINUS_D) }
@<Lexer rules for text handling@>
<INITIAL>@@d { start(fragmentHeader); DTOKEN(AT_SMALL_D) }
<INITIAL>@@D { start(fragmentHeader); DTOKEN(AT_LARGE_D) }
<INITIAL>@@o { start(outputFileHeader); DTOKEN(AT_SMALL_O) }
<INITIAL>@@O { start(outputFileHeader); DTOKEN(AT_LARGE_O) }
<INITIAL>@@f { DTOKEN(AT_SMALL_F) }
<scrapContents>@@< { start(fragmentExpansion); DTOKEN(AT_ANGLE_BRACKET_OPEN) }
<fragmentExpansion>@@> { start(scrapContents); DTOKEN(AT_ANGLE_BRACKET_CLOSE) }
<fragmentHeader,fragmentExpansion>@@' {  DTOKEN(AT_TICK) }
<fragmentHeader,scrapContents>@@[1-9] { DINTTOKEN(AT_NUMBER, std::stoi(std::string(yytext+1, yyleng-1))) }
<INITIAL,outputFileHeader,fragmentHeader>[@@][{] { start(scrapContents); DTOKEN(AT_CURLY_BRACKET_OPEN) }
<scrapContents>[@@][}] { start(INITIAL); DTOKEN(AT_CURLY_BRACKET_CLOSE) }
@}

@O ../src/nuweb.l
@{@@. { DSTRINGTOKEN(NOT_IMPLEMENTED) }
@<Lexer rule for end of file@>
%%
@}

\iffalse
 /* <scrapContents>"@@<"         { BEGIN(scrapContents); TOKEN(AT_ANGLE_BRACKET_OPEN) }
<scrapContents>"@@<+"        { BEGIN(scrapContents); TOKEN(AT_ANGLE_BRACKET_OPEN_PLUS) }
<scrapContents>"@@>"         { BEGIN(INITIAL); TOKEN(AT_ANGLE_BRACKET_CLOSE) }
<*>"@@_" { TOKEN(AT_UNDERLINE) }
<*>"@@v" { TOKEN(AT_V) }
<*>"@@o" { TOKEN(AT_SMALL_O) }
<*>"@@O" { TOKEN(AT_LARGE_O) }
<*>"@@d" { TOKEN(AT_SMALL_D) }
<*>"@@d+" { TOKEN(AT_SMALL_D_PLUS) }
<*>"@@D" { TOKEN(AT_LARGE_D) }
<*>"@@D+" { TOKEN(AT_LARGE_D_PLUS) }
<*>"@@q" { TOKEN(AT_SMALL_Q) }
<*>"@@q+" { TOKEN(AT_SMALL_Q_PLUS) }
<*>"@@Q" { TOKEN(AT_LARGE_Q) }
<*>"@@Q+" { TOKEN(AT_LARGE_Q_PLUS) }
<*>"@@f" { TOKEN(AT_SMALL_F) }
<*>"@@F" { TOKEN(AT_LARGE_F) }
<*>"@@'" { TOKEN(AT_TICK) }
<*>"@@x" { TOKEN(AT_X) }
<*>"@@t" { TOKEN(AT_T) }
<*>"@@#" { TOKEN(AT_HASH) }
<*>"@@s" { TOKEN(AT_SMALL_S) }
<*>"@@S" { TOKEN(AT_LARGE_S) }
<*>"@@m" { TOKEN(AT_M) }
<*>"@@m+" { TOKEN(AT_M_PLUS) }
<*>"@@u" { TOKEN(AT_U) }
<*>"@@u+" { TOKEN(AT_U_PLUS) }
<*>"@@%" { TOKEN(AT_PERCENT) }
<*>"@@|" { TOKEN(AT_PIPE) }
<*>"\-d" { TOKEN(FLAG_D) }
<*>"\-i" { TOKEN(FLAG_I) }
<*>"\-t" { TOKEN(FLAG_T) }
<*>"\-cc" { TOKEN(FLAG_C_C) }
<*>"\-c\+" { TOKEN(FLAG_C_PLUS) }
<*>"\-cp" { TOKEN(FLAG_C_P) }
<*>[@@][1-9] { TOKEN(AT_NUMBER) } */
\fi

@O ../src/nuweb.l
@{

 /* code */
@}


