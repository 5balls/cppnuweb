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

\subsection{Tokens and types}

\codebisonflex
@O ../src/nuweb.y
@{

%token FILENAME
%token AT_CURLY_BRACKET_OPEN AT_CURLY_BRACKET_CLOSE AT_SQUARE_BRACKET_OPEN AT_SQUARE_BRACKET_CLOSE AT_ROUND_BRACKET_OPEN AT_ROUND_BRACKET_CLOSE 
%token AT_AT AT_UNDERLINE AT_TICK AT_NUMBER AT_X AT_T AT_HASH AT_S AT_PERCENT AT_V AT_M AT_M_PLUS AT_U
%token AT_MINUS AT_PLUS AT_U_PLUS
%token AT_SMALL_O AT_LARGE_O AT_SMALL_F AT_LARGE_F 
%token NOT_IMPLEMENTED
%token AT_COMMA
@<Bison token definitions@>
@}

@O ../src/nuweb.y
@{
%union
{
    std::string* m_string;
    filePosition* m_filePosition;
    filePositionWithInt* m_intValue;
    filePositionWithString* m_stringValue;
@<Bison union definitions@>
}
@| m_int m_string m_filePosition m_intValue m_stringValue @}

@O ../src/nuweb.y
@{
@<Bison type definitions@>
%type <m_documentPart> texCode;
%type <m_documentPart> nuwebExpression;
%type <m_documentPart> outputFile;
%type <m_filePosition> AT_AT;
%type <m_stringValue> NOT_IMPLEMENTED;
%type <m_filePosition> AT_LARGE_D;
%type <m_filePosition> MINUS_D;
%type <m_intValue> AT_NUMBER;
@}
