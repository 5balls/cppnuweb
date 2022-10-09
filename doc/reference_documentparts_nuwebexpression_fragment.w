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

\subsubsection{Fragment}
\indexBackusNaur{fragmentDefinition}\indexBackusNaur{fragmentCommand}\begin{figure}[ht]
\begin{grammar}
<fragmentDefinition> ::= <fragmentCommand> <fragmentNameDefinition> <scrap>;
\alt <fragmentCommand> <fragmentNameDefinition> WHITESPACE <scrap>;

<fragmentCommand> ::= '@@d ';
\alt '@@D ';
\alt '@@q ';
\alt '@@Q ';
\end{grammar}
\caption{BNF for fragmentDefinition and fragmentCommand}
\end{figure}

\indexBackusNaur{fragmentNameDefinition}\indexBackusNaur{fragmentNamePartDefinition}\indexBackusNaur{fragmentNameText}\indexBackusNaur{fragmentNameArgument}\begin{figure}[ht]
\begin{grammar}
<fragmentNameDefinition> ::=  <fragmentNamePartDefinition>+

<fragmentNamePartDefinition> ::= <fragmentNameText>
\alt <fragmentNameArgument>

<fragmentNameText> ::= TEXT_WITHOUT_AT_OR_NEWLINE
\alt '@@'

<fragmentNameArgument> ::= '@@\'{}' [TEXT_WITHOUT_AT_OR_NEWLINE] '@@\'{}'
\end{grammar}
\caption{BNF for fragmentNameDefinition, fragmentNamePartDefinition, fragmentNameText and fragmentNameArgument}
\end{figure}

We have the following bison rules for fragments:
@d Bison rules
@{@%
@<\bisonRule{fragmentDefinition}@>
@<\bisonRule{fragmentCommand}@>
@<\bisonRule{fragmentNameDefinition}@>
@<\bisonRule{fragmentNamePartDefinition}@>
@<\bisonRule{fragmentNameArgument}@>
@<\bisonRule{fragmentNameText}@>
@<\bisonRule{fragmentNameArgumentOld}@>
@<\bisonRule{commaSeparatedFragmentArguments}@>
@<\bisonRule{commaSeparatedFragmentArgument}@>
@<\bisonRule{fragmentReference}@>
@<\bisonRule{fragmentNameReference}@>
@}

And the following bison type definitions:
@d Bison type definitions
@{@%
@<\bisonTypeDefinition{fragmentDefinition}@>
@<\bisonTypeDefinition{fragmentNameDefinition}@>
@<\bisonTypeDefinition{fragmentNamePartDefinition}@>
@<\bisonTypeDefinition{fragmentCommand}@>
@<\bisonTypeDefinition{fragmentNameText}@>
@<\bisonTypeDefinition{fragmentNameReference}@>
@<\bisonTypeDefinition{fragmentReference}@>
@}

@d \bisonRule{fragmentDefinition}
@{
fragmentDefinition
    : fragmentCommand fragmentNameDefinition scrap
    {
        switch($fragmentCommand){
            case fragmentType::DEFINITION:
                $$ = new fragmentDefinition($fragmentNameDefinition, $scrap);
                break;
            case fragmentType::DEFINITION_PAGEBREAK:
                $$ = new fragmentDefinition($fragmentNameDefinition, $scrap, true);
                break;
            case fragmentType::QUOTED:
                throw std::runtime_error("fragmentType::QUOTED not implemented\n");
                break;
            case fragmentType::QUOTED_PAGEBREAK:
                throw std::runtime_error("fragmentType::QUOTED_PAGEBREAK not implemented\n");
                break;
            default:
                throw std::runtime_error("Unknown fragmentType in fragmentDefinition!\n");
                break;
        }
    }
    | fragmentCommand fragmentNameDefinition WHITESPACE scrap
    {
        throw std::runtime_error("fragmentDefinition whitespace\n");
    }
;
@| fragmentDefinition @}

@d \bisonTypeDefinition{fragmentDefinition}
@{@%
%type <m_documentPart> fragmentDefinition
@}

@d \staticDefinitions{fragmentDefinition}
@{@%
unsigned int nuweb::fragmentDefinition::m_scrapNumber = 0;
std::map<unsigned int, nuweb::fragmentDefinition*> nuweb::fragmentDefinition::fragmentDefinitions = {};
std::map<unsigned int, std::vector<unsigned int> > nuweb::fragmentDefinition::m_scrapsDefiningAFragment = {};
@}

@d \bisonRule{fragmentCommand}
@{
fragmentCommand
    : AT_SMALL_D
    {
        $$ = fragmentType::DEFINITION;
    }
    | AT_LARGE_D
    {
        $$ = fragmentType::DEFINITION_PAGEBREAK;
    }
    | AT_SMALL_Q
    {
        $$ = fragmentType::QUOTED;
    }
    | AT_LARGE_Q
    {
        $$ = fragmentType::QUOTED_PAGEBREAK;
    }
;
@| fragmentCommand @}

We define a simple enum class type\footnote{Type:@d C++ enum class definitions in namespace nuweb
@{@%
enum class fragmentType {
    OUTPUT_FILE,
    OUTPUT_FILE_PAGEBREAK,
    DEFINITION,
    DEFINITION_PAGEBREAK,
    QUOTED,
    QUOTED_PAGEBREAK
};
@| fragmentType @}} for fragmentCommand and the tokens\footnote{Tokens:@d Bison token definitions
@{@%
%token AT_SMALL_D AT_LARGE_D AT_SMALL_Q AT_LARGE_Q
@| AT_SMALL_D AT_LARGE_D AT_SMALL_Q AT_LARGE_Q @}}, the type\footnote{Type:@d \bisonTypeDefinition{fragmentCommand}
@{@%
%type <m_fragmentType> fragmentCommand
@| fragmentCommand @}} and the union\footnote{Union:@d Bison union definitions
@{@%
enum fragmentType m_fragmentType;
@| m_fragmentType @}}. We have some simple rules for the fragment commands:
@d Lexer rules for fragment commands
@{@%
<INITIAL>@@d[ ] { start(fragmentHeader); TOKEN(AT_SMALL_D) }
<INITIAL>@@D[ ] { start(fragmentHeader); TOKEN(AT_LARGE_D) }
<INITIAL>@@q[ ] { start(fragmentHeader); TOKEN(AT_SMALL_Q) }
<INITIAL>@@Q[ ] { start(fragmentHeader); TOKEN(AT_LARGE_Q) }
@| AT_SMALL_D AT_LARGE_D AT_SMALL_Q AT_LARGE_Q @}

@d \bisonRule{fragmentNameDefinition}
@{
fragmentNameDefinition
    : fragmentNamePartDefinition
    {
        $$ = new documentPart();
        $$->push_back($fragmentNamePartDefinition);
    }
    | fragmentNameDefinition[l_fragmentNameDefinition] fragmentNamePartDefinition
    {
        $l_fragmentNameDefinition->push_back($fragmentNamePartDefinition);
        $$ = $l_fragmentNameDefinition;
    }
;
@| fragmentNameDefinition @}

@d \bisonTypeDefinition{fragmentNameDefinition}
@{@%
%type <m_documentPart> fragmentNameDefinition
@}

@d \bisonRule{fragmentNamePartDefinition}
@{
fragmentNamePartDefinition
    : fragmentNameText
    {
        $$ = new fragmentNamePartDefinition($fragmentNameText, false);
    }
    | fragmentNameArgument
    {
        throw std::runtime_error("fragmentNameArgument not implemented!\n");
    }
;
@| fragmentNamePartDefinition @}

@d \bisonTypeDefinition{fragmentNamePartDefinition}
@{@%
%type <m_documentPart> fragmentNamePartDefinition
@| fragmentNamePartDefinition @}

@d \classDeclaration{fragmentNamePartDefinition}
@{@%
class fragmentNamePartDefinition : public documentPart {
private:
    bool m_isArgument = false;
    static std::vector<fragmentNamePartDefinition*> m_allFragmentPartDefinitions;
public:
    fragmentNamePartDefinition(filePosition* l_filePosition, bool isArgument) : documentPart(l_filePosition), m_isArgument(isArgument) {
        m_allFragmentPartDefinitions.push_back(this);
    }
    fragmentNamePartDefinition(documentPart&& l_documentPart, bool isArgument) : documentPart(std::move(l_documentPart)), m_isArgument(isArgument) {
        m_allFragmentPartDefinitions.push_back(this);
    }
    bool operator==(const fragmentNamePartDefinition& toCompareWith){
        if(m_isArgument && toCompareWith.m_isArgument)
            return m_isArgument == toCompareWith.m_isArgument;
        else
            if(m_isArgument != toCompareWith.m_isArgument)
                return false;
            else
                return utf8() == toCompareWith.utf8();
    }
    virtual std::string texUtf8() const override {
        if(m_isArgument)
            return "\\hbox{\\slshape\\sffamily " + utf8() + "\\/}";
        else
            return utf8();
    }
};
@| fragmentNamePart @}

@d \staticDefinitions{fragmentNamePartDefinition}
@{@%
std::vector<nuweb::fragmentNamePartDefinition*> nuweb::fragmentNamePartDefinition::m_allFragmentPartDefinitions = {};
@| m_allFragmentPartDefinitions @}

\indexBisonRuleUsesToken{fragmentNameArgument}{TEXT\_WITHOUT\_AT}\indexBisonRuleUsesToken{fragmentNameArgument}{AT\_TICK}\indexBisonRuleUsesToken{fragmentNameArgument}{TEXT\_WITHOUT\_AT\_OR\_WHITESPACE}
@d \bisonRule{fragmentNameArgument}
@{
fragmentNameArgument
    : AT_TICK AT_TICK
    {
        throw std::runtime_error("AT_TICK AT_TICK not implemented!\n");
    }
    | AT_TICK TEXT_WITHOUT_AT_OR_NEWLINE AT_TICK
    {
        throw std::runtime_error("AT_TICK TEXT_WITHOUT_AT_OR_NEWLINE AT_TICK not implemented!\n");
    }
;
@| fragmentNameArgument @}

\indexBisonRuleUsesToken{fragmentNameText}{TEXT\_WITHOUT\_AT}\indexBisonRuleUsesToken{fragmentNameText}{AT\_AT}\indexBisonRuleUsesToken{fragmentNameText}{TEXT\_WITHOUT\_AT\_OR\_WHITESPACE}
@d \bisonRule{fragmentNameText}
@{
fragmentNameText
    : TEXT_WITHOUT_AT_OR_NEWLINE 
    {
        $$ = new documentPart($TEXT_WITHOUT_AT_OR_NEWLINE);
    }
    | AT_AT
    {
        $$ = new escapeCharacterDocumentPart($AT_AT);
    }
;
@| fragmentNameText @}

@d \bisonTypeDefinition{fragmentNameText}
@{%type <m_documentPart> fragmentNameText;
@} 

@d \bisonRule{fragmentNameArgumentOld}
@{
fragmentNameArgumentOld
    : AT_ROUND_BRACKET_OPEN commaSeparatedFragmentArguments AT_ROUND_BRACKET_CLOSE
    {
        throw std::runtime_error("AT_ROUND_BRACKET_OPEN commaSeparatedFragmentArguments AT_ROUND_BRACKET_CLOSE not implemented!\n");
    }
;
@| fragmentNameArgumentOld @}

@d \bisonRule{commaSeparatedFragmentArguments}
@{
commaSeparatedFragmentArguments
    : commaSeparatedFragmentArgument
    {
        throw std::runtime_error("commaSeparatedFragmentArgument not implemented!\n");
    }
    | commaSeparatedFragmentArguments AT_AT commaSeparatedFragmentArgument
    {
        throw std::runtime_error("commaSeparatedFragmentArguments AT_AT commaSeparatedFragmentArgument not implemented!\n");
    }
;
@| commaSeparatedFragmentArguments @}

\indexBisonRuleUsesToken{commaSeparatedFragmentArgument}{TEXT\_WITHOUT\_AT}
@d \bisonRule{commaSeparatedFragmentArgument}
@{
commaSeparatedFragmentArgument
    : TEXT_WITHOUT_AT
    {
        throw std::runtime_error("TEXT_WITHOUT_AT not implemented!\n");
    }
;
@| commaSeparatedFragmentArgument @}

@d \bisonRule{fragmentReference}
@{@%
fragmentReference
    : AT_ANGLE_BRACKET_OPEN fragmentNameReference AT_ANGLE_BRACKET_CLOSE
    {
        $$ = $fragmentNameReference;
    }
    | AT_ANGLE_BRACKET_OPEN fragmentNameReference fragmentNameArgumentOld AT_ANGLE_BRACKET_CLOSE
    {
        throw std::runtime_error("fragmentReference with old arguments not implemented\n");
    }
;
@| fragmentReference @}


@d Lexer rules for fragment headers and references
@{@%
<scrapContents>@@< { start(fragmentReference); TOKEN(AT_ANGLE_BRACKET_OPEN) }
<fragmentReference>@@> { start(scrapContents); TOKEN(AT_ANGLE_BRACKET_CLOSE) }
<fragmentHeader,fragmentReference>@@' {  TOKEN(AT_TICK) }
<fragmentHeader,scrapContents>@@[1-9] { DINTTOKEN(AT_NUMBER, std::stoi(std::string(yytext+1, yyleng-1))) }
@}

@d \bisonRule{fragmentNameReference}
@{@%
fragmentNameReference
    : fragmentNameDefinition
    {
        $$ = new fragmentReference($fragmentNameDefinition);
    }
@| fragmentNameReference @}

@d \bisonTypeDefinition{fragmentNameReference}
@{@%
%type <m_documentPart> fragmentNameReference
@}

@d \bisonTypeDefinition{fragmentReference}
@{@%
%type <m_documentPart> fragmentReference
@}


@d \classDeclaration{fragmentReference}
@{@%
class fragmentReference : public documentPart {
private:
    fragmentDefinition* m_fragment;
    documentPart* m_unresolvedFragmentName;
    unsigned int m_scrapNumber;
public:
    fragmentReference(documentPart* fragmentName) : m_unresolvedFragmentName(nullptr){
        m_fragment = fragmentDefinition::fragmentFromFragmentName(fragmentName);
        if(!m_fragment) m_unresolvedFragmentName = fragmentName;
        m_scrapNumber = fragmentDefinition::totalNumberOfScraps() + 1;
        if(m_fragment) m_fragment->addReferenceScrapNumber(m_scrapNumber);
    }
    virtual std::string utf8(void) const override {
        fragmentDefinition* fragment = m_fragment;
        if(!fragment) fragment = fragmentDefinition::fragmentFromFragmentName(m_unresolvedFragmentName);
        if(!fragment) throw std::runtime_error("Could not resolve fragment \"" + m_unresolvedFragmentName->texUtf8() + "\" in file " + m_unresolvedFragmentName->filePositionString());
        fragment->addReferenceScrapNumber(m_scrapNumber);
        return fragment->utf8();
    }
    virtual std::string texUtf8(void) const override {
        fragmentDefinition* fragment = m_fragment;
        if(!fragment) fragment = fragmentDefinition::fragmentFromFragmentName(m_unresolvedFragmentName);
        if(!fragment) throw std::runtime_error("Could not resolve fragment \"" + m_unresolvedFragmentName->texUtf8() + "\" in file " + m_unresolvedFragmentName->filePositionString());
        fragment->addReferenceScrapNumber(m_scrapNumber);
        std::string returnString = "@@\\hbox{$\\langle\\,${\\itshape ";
        returnString += fragment->name();
        returnString += "}\\nobreak\\ {\\footnotesize \\NWlink{nuweb";
        std::string scrapNumber = "?";
        if(documentPart::auxFileWasParsed())
            scrapNumber = auxFile::scrapId(fragment->scrapNumber());
        else
            std::cout << "No aux file yet, need to run Latex again!\n";
        returnString += scrapNumber + "}{" + scrapNumber + "}";
        if(fragment->scrapsFromFragment().size() > 1)
            returnString += ", \\ldots\\ ";
        if(listingsPackageEnabled())
            returnString += "}$\\,\\rangle$}\\lstinline@@";
        else
            returnString += "}$\\,\\rangle$}\\verb@@";
        return returnString;
    }
};
@}
