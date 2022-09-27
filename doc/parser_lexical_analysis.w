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

@<Lexer start conditions@>
%x outputFileHeader
%x fragmentHeader
%x fragmentExpansion

%%
 /* rules */
@<Lexer rule for including files@>
@<Lexer rule for escape character@>
<outputFileHeader>-d { DTOKEN(MINUS_D) }
@<Lexer rules for text handling@>
@<Lexer rules for fragment commands@>
<INITIAL>@@o { start(outputFileHeader); DTOKEN(AT_SMALL_O) }
<INITIAL>@@O { start(outputFileHeader); DTOKEN(AT_LARGE_O) }
<INITIAL>@@f { DTOKEN(AT_SMALL_F) }
@<Lexer rules for regular nuweb commands@>
<scrapContents>@@< { start(fragmentExpansion); DTOKEN(AT_ANGLE_BRACKET_OPEN) }
<fragmentExpansion>@@> { start(scrapContents); DTOKEN(AT_ANGLE_BRACKET_CLOSE) }
<fragmentHeader,fragmentExpansion>@@' {  DTOKEN(AT_TICK) }
<fragmentHeader,scrapContents>@@[1-9] { DINTTOKEN(AT_NUMBER, std::stoi(std::string(yytext+1, yyleng-1))) }
<INITIAL,outputFileHeader,fragmentHeader>[@@][{] { start(scrapContents); DTOKEN(AT_CURLY_BRACKET_OPEN) }
<scrapContents,userIdentifiers>[@@][}] { start(INITIAL); DTOKEN(AT_CURLY_BRACKET_CLOSE) }
@| AT_AT MINUS_D AT_SMALL_D AT_LARGE_D AT_SMALL_O AT_LARGE_O AT_SMALL_F AT_ANGLE_BRACKET_OPEN AT_ANGLE_BRACKET_CLOSE AT_TICK AT_NUMBER AT_CURLY_BRACKET_OPEN AT_CURLY_BRACKET_CLOSE @}

@O ../src/nuweb.l
@{<*>@@. { DSTRINGTOKEN(NOT_IMPLEMENTED) }
<*>. { DSTRINGTOKEN(NOT_IMPLEMENTED) }
@<Lexer rule for end of file@>
%%
@}

@O ../src/nuweb.l
@{

 /* code */
@}


