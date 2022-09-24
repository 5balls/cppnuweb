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

%token TEXT_WITHOUT_AT
%token FILENAME
%token AT_CURLY_BRACKET_OPEN AT_CURLY_BRACKET_CLOSE AT_SQUARE_BRACKET_OPEN AT_SQUARE_BRACKET_CLOSE AT_ROUND_BRACKET_OPEN AT_ROUND_BRACKET_CLOSE AT_ANGLE_BRACKET_OPEN AT_ANGLE_BRACKET_CLOSE AT_ANGLE_BRACKET_OPEN_PLUS 
%token AT_I AT_AT AT_UNDERLINE AT_TICK AT_NUMBER AT_X AT_T AT_HASH AT_S AT_PERCENT AT_V AT_M AT_M_PLUS AT_U
%token AT_PIPE AT_MINUS AT_PLUS AT_U_PLUS
%token MINUS_D
%token AT_SMALL_O AT_LARGE_O AT_SMALL_D AT_LARGE_D AT_SMALL_Q AT_LARGE_Q AT_SMALL_F AT_LARGE_F AT_LARGE_D_PLUS AT_SMALL_D_PLUS AT_LARGE_Q_PLUS AT_SMALL_S AT_SMALL_Q_PLUS AT_LARGE_S
%token NOT_IMPLEMENTED
%token WHITESPACE
%token TEXT_WITHOUT_AT_OR_WHITESPACE
%token AT_COMMA
@}

@O ../src/nuweb.y
@{
%union
{
    int m_int;
    std::string* m_string;
    filePosition* m_filePosition;
    filePositionWithInt* m_intValue;
    filePositionWithString* m_stringValue;
@<Bison union definitions@>
    texCode* m_texCode;
}
@}

@O ../src/nuweb.y
@{
@<Bison type definitions@>
%type <m_texCode> texCode;
%type <m_documentPart> nuwebExpression;
%type <m_documentPart> fragment;
%type <m_texCode> escapedchar;
%type <m_documentPart> outputFile;
%type <m_stringValue> TEXT_WITHOUT_AT;
%type <m_stringValue> AT_I;
%type <m_stringValue> TEXT_WITHOUT_AT_OR_WHITESPACE;
%type <m_stringValue> outputFilename;
%type <m_filePosition> AT_AT;
%type <m_stringValue> WHITESPACE;
%type <m_stringValue> NOT_IMPLEMENTED;
%type <m_filePosition> AT_LARGE_D;
%type <m_filePosition> MINUS_D;
%type <m_intValue> AT_NUMBER;
@}
