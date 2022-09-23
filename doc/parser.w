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

@<Parse parameters@>
@<Flex parameters@>
@}

@i parser_glue_code.w

@i parser_tokens.w

\subsection{Rules}
The following rules are used to create the parser for nuweb. They also define a grammar for nuweb files in Backus-Naur form. I am not aware of previous work to describe the nuweb grammar this way, so there are likely some errors.

\subsubsection{Document structure}
First, each nuweb document ends with a end of file marker (which we don't consider part of \lstinline{document}):

\begin{figure}[ht]
\begin{grammar}
<nuwebAstRoot> ::= <document> YYEOF;
\end{grammar}
\caption{BNF for nuwebAstRoot}
\end{figure}

In the code, we pass \lstinline{document} to the class pointer \codecpp\lstinline{*l_document}\codebisonflex.

@O ../src/nuweb.y
@{
%%
 /* rules */
nuwebAstRoot
    : document YYEOF
    {
        *l_document = $document;
    }
;
@}

Each document consists of a list of document documentParts. We achieve this by matching an empty string to \lstinline{document} and afterwards match consecutively matched \lstinline{documentPart} to the right and add them to the list of documentParts in \lstinline{document}.

\begin{figure}[ht]
\begin{grammar}
<document> ::= $\epsilon$
\alt <document> <documentPart>;
\end{grammar}
\caption{BNF for document}
\end{figure}

The \lstinline{%empty} rule is only matched at the beginning.

@O ../src/nuweb.y
@{
document
    : %empty
    {
        $$ = new document();
    }
    | document[l_document] documentPart
    {
        $l_document->addElement($documentPart);
        $$ = $l_document;
    }
;
@}

An \lstinline{documentPart} can be one of three types:

\begin{enumerate}
\item texCode
\item nuwebExpression
\item outputFile
\end{enumerate}

@O ../src/nuweb.y
@{
documentPart
    : texCode
    {
        $$ = $texCode;
    }
    | nuwebExpression
    | outputFile
;

texCode
    : TEXT_WITHOUT_AT
    {
        $$ = new texCode(*$TEXT_WITHOUT_AT);
    }
    | WHITESPACE
    {
        $$ = new texCode(*$WHITESPACE);
    }
    | TEXT_WITHOUT_AT_OR_WHITESPACE
    {
        $$ = new texCode(*$TEXT_WITHOUT_AT_OR_WHITESPACE);
    }
;

nuwebExpression
    : AT_I
    {
        $$ = new includeFile(*$AT_I);
    }
    | escapedchar
    {
        $$ = $escapedchar;
    }
    | scrap
    {
        std::cout << "scrap\n";
    }
    | fragment
    {
        std::cout << "fragment in nuwebExpression\n";
    }
    | AT_SMALL_F
    {
        std::cout << "@@f not implemented\n";
    }
    | NOT_IMPLEMENTED
    {
        std::cout << "  " << $NOT_IMPLEMENTED->m_filename << ":" << $NOT_IMPLEMENTED->m_line << ":" << $NOT_IMPLEMENTED->m_column << " command \"" << $NOT_IMPLEMENTED->m_value << "\" not implemented!\n";
    }
;
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
        std::cout << "outputCommand with filename »" << $outputFilename->m_value << "« and flags\n";
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
