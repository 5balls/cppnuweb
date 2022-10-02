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

\subsection{\TeX{} code}
``\lstinline{texCode}'' is any text that appears directly in the document and does not contain any ``@@'' character. As such ``\lstinline{TEXT_WITHOUT_AT}'' would be sufficient, but other rules may match before \todorefactor{Is that really the case? Check that}that. It does not hurt to have this additional rules here and ``\lstinline{WHITESPACE}'' and ``\lstinline{TEXT_WITHOUT_AT_OR_WHITESPACE}'' are needed later anyway.

\indexBackusNaur{texCode}\begin{figure}[ht]
\begin{grammar}
<texCode> ::= TEXT_WITHOUT_AT
\alt WHITESPACE
\alt TEXT_WITHOUT_AT_OR_WHITESPACE
\end{grammar}
\caption{BNF for texCode}
\end{figure}

All of those are creating an \codecpp\lstinline{documentPart} object.

\indexBisonRule{texCode}\indexBisonRuleUsesToken{texCode}{TEXT\_WITHOUT\_AT}\indexBisonRuleUsesToken{texCode}{WHITESPACE}\indexBisonRuleUsesToken{texCode}{TEXT\_\-WITHOUT\_\-AT\_\-OR\_\-WHITESPACE}
@d Bison rules
@{
texCode
    : TEXT_WITHOUT_AT
    {
        std::cout << "Bison texCode:TEXT_WITHOUT_AT\n" << std::flush;
        $$ = new documentPart($TEXT_WITHOUT_AT);
    }
    | WHITESPACE
    {
        $$ = new documentPart($WHITESPACE);
    }
    | TEXT_WITHOUT_AT_OR_WHITESPACE
    {
        $$ = new documentPart($TEXT_WITHOUT_AT_OR_WHITESPACE);
    }
;
@| texCode @}

We have the following Flex rules for this

\indexFlexRule{WHITESPACE}\indexFlexRule{TEXT\_\-WITHOUT\_\-AT\_\-OR\_\-WHITESPACE}\indexFlexRule{TEXT\_WITHOUT\_AT}
@d Lexer rules for text handling
@{<outputFileHeader,userIdentifiers>[[:space:]]+  { DTOKEN(WHITESPACE) }
<outputFileHeader,userIdentifiers>[^@@[:space:]]+ { DTOKEN(TEXT_WITHOUT_AT_OR_WHITESPACE) }
<INITIAL,scrapContents,fragmentHeader,fragmentExpansion>[^@@]+ { DTOKEN(TEXT_WITHOUT_AT) } @| WHITESPACE TEXT_WITHOUT_AT_OR_WHITESPACE TEXT_WITHOUT_AT @}

and our type definitions\footnote{\begin{samepage}Types (note that \codecpp\lstinline{filePosition} is good enough here as we can get the string part from our internal file buffer list):@d Bison type definitions
@{%type <m_filePosition> WHITESPACE;
%type <m_filePosition> TEXT_WITHOUT_AT_OR_WHITESPACE;
%type <m_filePosition> TEXT_WITHOUT_AT;
@| WHITESPACE TEXT_WITHOUT_AT_OR_WHITESPACE TEXT_WITHOUT_AT @}\indexBisonType{WHITESPACE}\indexBisonType{TEXT_WITHOUT_AT_OR_WHITESPACE}\indexBisonType{TEXT_WITHOUT_AT}\end{samepage}} and tokens\footnote{\begin{samepage}Tokens:@d Bison token definitions
@{%token TEXT_WITHOUT_AT_OR_WHITESPACE
%token WHITESPACE
%token TEXT_WITHOUT_AT
@| WHITESPACE TEXT_WITHOUT_AT_OR_WHITESPACE TEXT_WITHOUT_AT @}\end{samepage}}.

