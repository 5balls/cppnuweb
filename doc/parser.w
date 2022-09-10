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

\subsection{Lexical analysis}
@O ../src/nuweb.l
@{
%{
#include <iostream>
#include "parser.hpp"


extern int yylex(void);
#define TOKEN(X) return yytokentype::X;
%}

 /*%option c++ */
%option noyywrap
%option yylineno

 /* %option prefix="nuweb" */
%x fragment


%%
 /* rules */
<INITIAL>"@@{" { BEGIN(fragment); TOKEN(AT_CURLY_BRACKET_OPEN) }
<fragment>"@@}" { BEGIN(INITIAL); TOKEN(AT_CURLY_BRACKET_CLOSE) }
<INITIAL>"@@[" { BEGIN(fragment); TOKEN(AT_SQUARE_BRACKET_OPEN) }
<fragment>"@@]" { BEGIN(INITIAL); TOKEN(AT_SQUARE_BRACKET_CLOSE) }
<INITIAL,fragment>"@@(" { BEGIN(fragment); TOKEN(AT_ROUND_BRACKET_OPEN) }
<fragment>"@@)" { BEGIN(INITIAL); TOKEN(AT_ROUND_BRACKET_CLOSE) }
<fragment>"@@<" { BEGIN(fragment); TOKEN(AT_ANGLE_BRACKET_OPEN) }
<fragment>"@@<+" { BEGIN(fragment); TOKEN(AT_ANGLE_BRACKET_OPEN_PLUS) }
<fragment>"@@>" { BEGIN(INITIAL); TOKEN(AT_ANGLE_BRACKET_CLOSE) }
<*>"@@@@" { TOKEN(AT_AT) }
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
<*>"@@+" { TOKEN(AT_PLUS) }
<*>"@@+" { TOKEN(AT_MINUS) }
<*>"@@[1-9]" { TOKEN(AT_NUMBER) } 
<*>"-d" { TOKEN(FLAG_D) }
<*>"-i" { TOKEN(FLAG_I) }
<*>"-t" { TOKEN(FLAG_T) }
<*>"-cc" { TOKEN(FLAG_C_C) }
<*>"-c+" { TOKEN(FLAG_C_PLUS) }
<*>"-cp" { TOKEN(FLAG_C_P) }
<<EOF>> { TOKEN(YYEOF) }
%%

 /* code */
@}

\subsection{Context free grammar}
@O ../src/nuweb.y
@{

%require "3.2"

%{
    #include <iostream>
    extern int yylex(void);
    void yyerror (char const *s){
        /* TODO Throw error here */
        std::cout << s;
    };
%}

%token TEX_WITHOUT_AT
%token FILENAME
%token AT_CURLY_BRACKET_OPEN AT_CURLY_BRACKET_CLOSE AT_SQUARE_BRACKET_OPEN AT_SQUARE_BRACKET_CLOSE AT_ROUND_BRACKET_OPEN AT_ROUND_BRACKET_CLOSE AT_ANGLE_BRACKET_OPEN AT_ANGLE_BRACKET_CLOSE AT_ANGLE_BRACKET_OPEN_PLUS 
%token AT_I AT_AT AT_UNDERLINE AT_TICK AT_NUMBER AT_X AT_T AT_HASH AT_S AT_PERCENT AT_V AT_M AT_M_PLUS AT_U
%token AT_PIPE AT_MINUS AT_PLUS AT_U_PLUS
%token FLAG_D FLAG_I FLAG_T FLAG_C_C FLAG_C_PLUS FLAG_C_P
%token AT_SMALL_O AT_LARGE_O AT_SMALL_D AT_LARGE_D AT_SMALL_Q AT_LARGE_Q AT_SMALL_F AT_LARGE_F AT_LARGE_D_PLUS AT_SMALL_D_PLUS AT_LARGE_Q_PLUS AT_SMALL_S AT_SMALL_Q_PLUS AT_LARGE_S

%union
{
    int m_int;
}

%type <m_texCode> TEX_WITHOUT_AT

%%
 /* rules */
NUWEBFILE
    : statements YYEOF
;

statements
    : %empty
    | statements statement
;

statement
    : TEX_WITHOUT_AT
    | fragment
    | include
    | escapedchar
;

fragment
    : AT_CURLY_BRACKET_OPEN fragmentinside AT_CURLY_BRACKET_CLOSE
;

fragmentinside
    : AT_AT
;

include
    : AT_I includefilename
;

includefilename
    : FILENAME
;

escapedchar
    : AT_AT
;
%%
 /* code */
@}
