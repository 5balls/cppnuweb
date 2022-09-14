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

#define DEBUG_LEXER(X) std::cout << X << " "; std::cout.flush();
#define TOKEN(X) DEBUG_LEXER(#X) return yy::parser::token::yytokentype::X;
%}

%option c++
%option noyywrap
%option yylineno
%option yyclass="helpLexer"

%x scrapContents


%%
 /* rules */
[^@@]+ { yylvalue->m_string = new std::string(yytext, yyleng); TOKEN(TEX_WITHOUT_AT) }
<INITIAL>"@@{" { BEGIN(scrapContents); TOKEN(AT_CURLY_BRACKET_OPEN) }
<scrapContents>"@@}" { BEGIN(INITIAL); TOKEN(AT_CURLY_BRACKET_CLOSE) }
<INITIAL>"@@[" { BEGIN(scrapContents); TOKEN(AT_SQUARE_BRACKET_OPEN) }
<scrapContents>"@@]" { BEGIN(INITIAL); TOKEN(AT_SQUARE_BRACKET_CLOSE) }
<INITIAL,scrapContents>"@@(" { BEGIN(scrapContents); TOKEN(AT_ROUND_BRACKET_OPEN) }
<scrapContents>"@@)"         { BEGIN(INITIAL); TOKEN(AT_ROUND_BRACKET_CLOSE) }
<scrapContents>"@@<"         { BEGIN(scrapContents); TOKEN(AT_ANGLE_BRACKET_OPEN) }
<scrapContents>"@@<+"        { BEGIN(scrapContents); TOKEN(AT_ANGLE_BRACKET_OPEN_PLUS) }
<scrapContents>"@@>"         { BEGIN(INITIAL); TOKEN(AT_ANGLE_BRACKET_CLOSE) }
<*>"@@@@"               { TOKEN(AT_AT) }
<*>"@@_" { TOKEN(AT_UNDERLINE) }
<*>"@@i" { TOKEN(AT_I) }
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
<*>[@@][1-9] { TOKEN(AT_NUMBER) } 
<<EOF>> { TOKEN(YYEOF) }
%%

 /* code */
@}


