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
\alt <fragmentExpansion>;
\end{grammar}
\caption{BNF for scrap and scrapElement}
\end{figure}

\indexBisonRule{scrap}\indexBisonRuleUsesToken{scrap}{AT\_CURLY\_BRACKET\_OPEN}\indexBisonRuleUsesToken{scrap}{AT\_CURLY\_BRACKET\_CLOSE}\indexBisonRuleUsesToken{scrap}{AT\_SQUARE\_BRACKET\_OPEN}\indexBisonRuleUsesToken{scrap}{AT\_SQUARE\_BRACKET\_CLOSE}\indexBisonRuleUsesToken{scrap}{AT\_ROUND\_BRACKET\_OPEN}\indexBisonRuleUsesToken{scrap}{AT\_ROUND\_BRACKET\_CLOSE}
@d Bison rules
@{
scrap
    : AT_CURLY_BRACKET_OPEN scrapContents AT_CURLY_BRACKET_CLOSE
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

@d \classDeclaration{scrap}
@{@%
class scrap : public documentPart {
public:
    scrap(const scrap&) = delete;
    scrap(scrap&& l_scrap) : documentPart(std::move(l_scrap)){
    }
    scrap(documentPart* l_documentPart) : documentPart(l_documentPart){
    }
};
@| scrap @}

@d Bison union definitions
@{@%
scrap* m_scrap;
@| m_scrap @}

@d Bison type definitions
@{@%
%type <m_scrap> scrap
@}

@d \classDeclaration{scrapVerbatim}
@{@%
class scrapVerbatim : public scrap {
public:
    scrapVerbatim(const scrapVerbatim&) = delete;
    scrapVerbatim(scrapVerbatim&& l_scrapVerbatim) : scrap(std::move(l_scrapVerbatim)) {
    }
    scrapVerbatim(documentPart* l_documentPart) : scrap(l_documentPart) {
    }
    virtual std::string texUtf8(void) const override {
        std::stringstream documentLines(documentPart::texUtf8());
        std::string documentLine;
        std::string returnString;
        while(std::getline(documentLines,documentLine))
            returnString += "\\lstinline@@" + documentLine + "@@\n";
        return returnString;
    }
};
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
        throw std::runtime_error("User identifiers not implemented!");
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
<scrapContents>@@\| { start(userIdentifiers); DSTRINGTOKEN(AT_PIPE) }
@| AT_PIPE @}

The user identifiers do not allow any nuweb commands inside it, so we define a new start condition \lstinline{userIdentifiers} for it. This ends with \lstinline{AT_CURLY_BRACKET_CLOSE} or similar, so we are fine here.

@d Bison rules
@{
userIdentifiers
    : WHITESPACE TEXT_WITHOUT_AT_OR_WHITESPACE WHITESPACE
    {
        throw std::runtime_error("User identifiers not implemented!");
    }
    | userIdentifiers TEXT_WITHOUT_AT_OR_WHITESPACE WHITESPACE
    {
        throw std::runtime_error("User identifiers not implemented!");
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
        throw std::runtime_error("AT_NUMBER\n");
    }
    | fragmentExpansion
    {
        throw std::runtime_error("fragmentExpansion\n");
    }
;
@| scrapElement @}

@d Bison type definitions
@{%type <m_documentPart> scrapElement
@}

