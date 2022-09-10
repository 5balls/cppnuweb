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
<INITIAL>"@@{" { BEGIN(fragment); TOKEN(AT_BRACE_OPEN)}
<fragment>"@@}" { BEGIN(INITIAL); TOKEN(AT_BRACE_CLOSE)}
<*>"@@@@" { std::cout << "@@ Character";}
<<EOF>> { std::cout << "End of file"; return 0;}
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
        std::cout << s;
    };
%}

%token TEXCODE
%token FILENAME
%token AT_BRACE_OPEN AT_BRACE_CLOSE AT_I AT_AT

%union
{
    int m_int;
}

%type <m_texCode> TEXCODE

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
    : TEXCODE
    | fragment
    | include
    | escapedchar
;

fragment
    : AT_BRACE_OPEN fragmentinside AT_BRACE_CLOSE
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
