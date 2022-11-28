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

\subsubsection{Scrap}
A scrap can be typeset in three ways, as verbatim, as paragraph or as math:

\indexBackusNaur{scrap}\indexBackusNaur{scrapElement}
\begin{figure}[ht]
\begin{grammar}
<scrap> ::= '@@\{' <scrapElement>+ '@@\}'; verbatim
\alt '@@[' <scrapElement>+ '@@]'; paragraph
\alt '@@(' <scrapElement>+ '@@)'; math

<scrapElement> ::= TEXT\_WITHOUT\_AT;
\alt AT\_AT;
\alt WHITESPACE;
\alt AT\_NUMBER;
\alt <fragmentReference>;
\end{grammar}
\caption{BNF for scrap and scrapElement}
\end{figure}

\indexBisonRule{scrap}\indexBisonRuleUsesToken{scrap}{AT\_CURLY\_BRACKET\_OPEN}\indexBisonRuleUsesToken{scrap}{AT\_CURLY\_BRACKET\_CLOSE}\indexBisonRuleUsesToken{scrap}{AT\_SQUARE\_BRACKET\_OPEN}\indexBisonRuleUsesToken{scrap}{AT\_SQUARE\_BRACKET\_CLOSE}\indexBisonRuleUsesToken{scrap}{AT\_ROUND\_BRACKET\_OPEN}\indexBisonRuleUsesToken{scrap}{AT\_ROUND\_BRACKET\_CLOSE}
@d Bison rules
@{
scrap
    : AT_CURLY_BRACKET_OPEN AT_CURLY_BRACKET_CLOSE
    {
        $$ = new scrapVerbatim(new emptyDocumentPart());
    }
    | AT_CURLY_BRACKET_OPEN scrapContents AT_CURLY_BRACKET_CLOSE
    {
        $$ = new scrapVerbatim($scrapContents);
    }
    | AT_CURLY_BRACKET_OPEN scrapContents AT_CURLY_BRACKET_CLOSE WHITESPACE
    {
        $$ = new scrapVerbatim($scrapContents);
    }
    | AT_SQUARE_BRACKET_OPEN scrapContents AT_SQUARE_BRACKET_CLOSE
    {
        throw std::runtime_error("scrap (paragraph)\n");
    }
    | AT_ROUND_BRACKET_OPEN scrapContents AT_ROUND_BRACKET_CLOSE
    {
        throw std::runtime_error("scrap (math)\n");
    }
;
@| scrap @}

@d Bison union definitions
@{@%
scrap* m_scrap;
@| m_scrap @}

@d Bison type definitions
@{@%
%type <m_scrap> scrap
@}

\todoimplement{Move constructors for documentPart}
Some commands are only valid inside a scrap, so we define a specific start condition for scraps:

@d Lexer start conditions
@{
%x scrapContents
@| scrapContents @}

@d Bison rules
@{
scrapContents
    : scrapElements
    {
        $$ = $scrapElements;
    }
    | scrapElements AT_PIPE userIdentifiers
    {
        $$ = $scrapElements;
        for(const auto& userIdentifier: *$userIdentifiers)
            $$->push_back(userIdentifier);
        delete $userIdentifiers;
    }
;
@| scrapContents @}

@d Bison type definitions
@{%type <m_documentPart> scrapContents
%type <m_documentPart> AT_PIPE
%type <m_documentPart> userIdentifiers
@}

@d Lexer rules for regular nuweb commands
@{
<scrapContents>@@\| { start(userIdentifiers); STRINGTOKEN(AT_PIPE) }
@| AT_PIPE @}

The user identifiers do not allow any nuweb commands inside it, so we define a new start condition \lstinline{userIdentifiers} for it. This ends with \lstinline{AT_CURLY_BRACKET_CLOSE} or similar, so we are fine here.

@d Bison rules
@{
userIdentifiers
    : WHITESPACE TEXT_WITHOUT_AT_OR_WHITESPACE WHITESPACE
    {
        $$ = new documentPart();
        $$->push_back(new userIdentifiers($TEXT_WITHOUT_AT_OR_WHITESPACE));
    }
    | userIdentifiers[l_userIdentifiers] TEXT_WITHOUT_AT_OR_WHITESPACE WHITESPACE
    {
        $l_userIdentifiers->push_back(new userIdentifiers($TEXT_WITHOUT_AT_OR_WHITESPACE));
    }
;
@| userIdentifiers @}

@d Lexer start conditions
@{
%x userIdentifiers
@| userIdentifiers @}

@d Bison token definitions
@{
%token AT_PIPE
@| AT_PIPE @}

@d Bison rules
@{
scrapElements
    : scrapElement
    {
        $$ = new documentPart();
        $$->push_back($scrapElement);
    }
    | scrapElements[l_scrapElements] scrapElement
    {
        $l_scrapElements->push_back($scrapElement);
        $$ = $l_scrapElements;
    }
;
@| scrapElements @}

@d Bison type definitions
@{%type <m_documentPart> scrapElements
@}

\indexBisonRuleUsesToken{scrapElement}{TEXT\_WITHOUT\_AT}
@d Bison rules
@{
scrapElement
    : TEXT_WITHOUT_AT
    {
        $$ = new documentPart($TEXT_WITHOUT_AT);
    }
    | AT_AT
    {
        throw std::runtime_error("AT_AT\n");
    }
    | WHITESPACE
    {
        throw std::runtime_error("WHITESPACE\n");
    }
    | AT_NUMBER
    {
        $$ = new fragmentArgument($AT_NUMBER->mn_value);
    }
    | fragmentReference
    {
        $$ = $fragmentReference;
    }
    | AT_SMALL_V
    {
        $$ = new versionString($AT_SMALL_V);
    }
;
@| scrapElement @}

@d Bison type definitions
@{%type <m_documentPart> scrapElement
@}

