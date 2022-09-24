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

@i parser_lexical_analysis.w

\section{Context free grammar}

The context free grammar is defined by a Bison file. We use the C++ code generator of Bison as well as the C++ code generator for Flex which leads to some extra work.

@O ../src/nuweb.y
@{

%require "3.2"
%language "c++"

@<Bison parse parameters first@>
@<Bison parse parameters@>
@<Bison flex parameters@>
@}

@i parser_glue_code.w

@i parser_tokens.w

\subsection{Rules}

The following rules are used to create the parser for nuweb. They also define a grammar for nuweb files in Backus-Naur form. 

In the code, we pass \lstinline{document} to the class pointer \codecpp\lstinline{*l_document}\codebisonflex.

@O ../src/nuweb.y
@{
%%
 /* rules */
@<Bison rules@>
@}


\subsection{Output file}
@O ../src/nuweb.y
@{
outputFile
    : outputCommand WHITESPACE outputFilename WHITESPACE scrap
    {
        std::cout << "outputCommand\n";
    }
    | outputCommand WHITESPACE outputFilename WHITESPACE outputFlags WHITESPACE scrap
    {
        std::cout << "outputCommand with filename \"" << $outputFilename->m_value << "\" and flags\n";
    }
;

outputCommand
    : AT_SMALL_O
    | AT_LARGE_O
;

outputFilename
    : TEXT_WITHOUT_AT_OR_WHITESPACE
;

outputFlags
    : MINUS_D
;
@}


\subsection{Fragment}
@O ../src/nuweb.y
@{
fragment
    : fragmentCommand fragmentName scrap
    {
        std::cout << "fragment\n";
    }
    | fragmentCommand fragmentName WHITESPACE scrap
    {
        std::cout << "fragment whitespace\n";
    }
;

fragmentCommand
    : AT_SMALL_D
    | AT_LARGE_D
    {
        std::cout << "large d\n";
    }
    | AT_SMALL_Q
;

fragmentName
    : fragmentNameText
    | fragmentNameArgument
    | fragmentName fragmentNameText
    | fragmentName fragmentNameArgument
//    | fragmentNameArgumentOld
;

fragmentNameArgument
    : AT_TICK AT_TICK
    | AT_TICK TEXT_WITHOUT_AT AT_TICK
    | AT_TICK TEXT_WITHOUT_AT_OR_WHITESPACE AT_TICK
;

fragmentNameText
    : TEXT_WITHOUT_AT 
    | AT_AT
    | TEXT_WITHOUT_AT_OR_WHITESPACE
;

fragmentNameArgumentOld
    : AT_ROUND_BRACKET_OPEN commaSeparatedFragmentArguments AT_ROUND_BRACKET_CLOSE
;

commaSeparatedFragmentArguments
    : %empty
    | commaSeparatedFragmentArguments AT_AT commaSeparatedFragmentArgument
;

commaSeparatedFragmentArgument
    : TEXT_WITHOUT_AT
;

fragmentExpansion
    : AT_ANGLE_BRACKET_OPEN fragmentName AT_ANGLE_BRACKET_CLOSE
;
@}

\subsection{Scrap}
A scrap can be typeset in three ways, as verbatim, as paragraph or as math:

\begin{figure}[ht]
\begin{grammar}
<scrap> ::= '@@\{' <scrapElements> '@@\}'; verbatim
\alt '@@[' <scrapElements> '@@]'; paragraph
\alt '@@(' <scrapElements> '@@)'; math
\end{grammar}
\caption{BNF for scrap}
\end{figure}

@O ../src/nuweb.y
@{
scrap
    : AT_CURLY_BRACKET_OPEN scrapElements AT_CURLY_BRACKET_CLOSE
    | AT_SQUARE_BRACKET_OPEN scrapElements AT_SQUARE_BRACKET_CLOSE
    | AT_ROUND_BRACKET_OPEN scrapElements AT_ROUND_BRACKET_CLOSE
;

scrapElements
    : scrapElement
    | scrapElements scrapElement
;

scrapElement
    : TEXT_WITHOUT_AT
    | AT_AT
    | WHITESPACE
    | AT_NUMBER
    | fragmentExpansion
;

escapedchar
    : AT_AT
    {
        $$ = new texCode(filePositionWithString(*$AT_AT, "@@"));
    }
;
%%
 /* code */
@<Function definition for int yylex(yy::parser::semantic_type* yylvalue);@>
@}

@i ast.w
