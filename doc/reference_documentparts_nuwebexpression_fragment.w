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
@d Bison rules
@{
fragmentDefinition
    : fragmentCommand fragmentNameDefinition scrap
    {
        switch($fragmentCommand){
            case fragmentType::DEFINITION:
                throw std::runtime_error("fragmentType::DEFINITION not implemented\n");
                break;
            case fragmentType::DEFINITION_PAGEBREAK:
                throw std::runtime_error("fragmentType::DEFINITION_PAGEBREAK not implemented\n");
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

@d \classDeclaration{fragmentDefinition}
@{@%
class fragmentDefinition : public documentPart {
private:
public:
fragmentDefinition(
};
@| fragmentDefinition @}

@d Bison rules
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
@| AT_SMALL_D AT_LARGE_D AT_SMALL_Q AT_LARGE_Q @}}, the type\footnote{Type:@d Bison type definitions
@{@%
%type <m_fragmentType> fragmentCommand
@| fragmentCommand @}} and the union\footnote{Union:@d Bison union definitions
@{@%
enum fragmentType m_fragmentType;
@| m_fragmentType @}}. We have some simple rules for the fragment commands:
@d Lexer rules for fragment commands
@{@%
<INITIAL>@@d { start(fragmentHeader); DTOKEN(AT_SMALL_D) }
<INITIAL>@@D { start(fragmentHeader); DTOKEN(AT_LARGE_D) }
<INITIAL>@@q { start(fragmentHeader); DTOKEN(AT_SMALL_Q) }
<INITIAL>@@Q { start(fragmentHeader); DTOKEN(AT_LARGE_Q) }
@| AT_SMALL_D AT_LARGE_D AT_SMALL_Q AT_LARGE_Q @}

@d Bison rules
@{
fragmentNameDefinition
    : fragmentNamePartDefinition
    {
        $$ = $fragmentNamePartDefinition;
    }
    | fragmentNameDefinition fragmentNamePartDefinition
    {
        throw std::runtime_error("fragmentName fragmentNamePart not implemented!\n");
    }
;
@| fragmentNameDefinition @}

@d Bison type definitions
@{@%
%type <m_documentPart> fragmentNameDefinition
@}


@d Bison rules
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

@d Bison type definitions
@{@%
%type <m_documentPart> fragmentNamePartDefinition
@| fragmentNamePartDefinition @}

@d \classDeclaration{fragmentNamePartDefinition}
@{@%
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
@| fragmentNamePart @}

@d \staticDefinitions{fragmentNamePartDefinition}
@{@%
std::vector<nuweb::fragmentNamePartDefinition*> nuweb::fragmentNamePartDefinition::m_allFragmentPartDefinitions = {};
@| m_allFragmentPartDefinitions @}

\indexBisonRuleUsesToken{fragmentNameArgument}{TEXT\_WITHOUT\_AT}\indexBisonRuleUsesToken{fragmentNameArgument}{AT\_TICK}\indexBisonRuleUsesToken{fragmentNameArgument}{TEXT\_WITHOUT\_AT\_OR\_WHITESPACE}
@d Bison rules
@{
fragmentNameArgument
    : AT_TICK AT_TICK
    {
        throw std::runtime_error("AT_TICK AT_TICK not implemented!\n");
    }
    | AT_TICK TEXT_WITHOUT_AT AT_TICK
    {
        throw std::runtime_error("AT_TICK TEXT_WITHOUT_AT AT_TICK not implemented!\n");
    }
    | AT_TICK TEXT_WITHOUT_AT_OR_WHITESPACE AT_TICK
    {
        throw std::runtime_error("AT_TICK TEXT_WITHOUT_AT_OR_WHITESPACE AT_TICK not implemented!\n");
    }
;
@| fragmentNameArgument @}

\indexBisonRuleUsesToken{fragmentNameText}{TEXT\_WITHOUT\_AT}\indexBisonRuleUsesToken{fragmentNameText}{AT\_AT}\indexBisonRuleUsesToken{fragmentNameText}{TEXT\_WITHOUT\_AT\_OR\_WHITESPACE}
@d Bison rules
@{
fragmentNameText
    : TEXT_WITHOUT_AT 
    {
        $$ = new documentPart($TEXT_WITHOUT_AT);
    }
    | AT_AT
    {
        $$ = new escapeCharacterDocumentPart($AT_AT);
    }
    | TEXT_WITHOUT_AT_OR_WHITESPACE
    {
        $$ = new documentPart($TEXT_WITHOUT_AT_OR_WHITESPACE);
    }
;
@| fragmentNameText @}

@d Bison type definitions
@{%type <m_documentPart> fragmentNameText;
@} 


@d Bison rules
@{
fragmentNameArgumentOld
    : AT_ROUND_BRACKET_OPEN commaSeparatedFragmentArguments AT_ROUND_BRACKET_CLOSE
    {
        throw std::runtime_error("AT_ROUND_BRACKET_OPEN commaSeparatedFragmentArguments AT_ROUND_BRACKET_CLOSE not implemented!\n");
    }
;
@| fragmentNameArgumentOld @}

@d Bison rules
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
@d Bison rules
@{
commaSeparatedFragmentArgument
    : TEXT_WITHOUT_AT
    {
        throw std::runtime_error("TEXT_WITHOUT_AT not implemented!\n");
    }
;
@| commaSeparatedFragmentArgument @}

@d Bison rules
@{@%
fragmentExpansion
    : AT_ANGLE_BRACKET_OPEN fragmentNameExpansion AT_ANGLE_BRACKET_CLOSE
    {
        throw std::runtime_error("fragmentExpansion not implemented\n");
    }
    | AT_ANGLE_BRACKET_OPEN fragmentNameExpansion fragmentNameArgumentOld AT_ANGLE_BRACKET_CLOSE
    {
        throw std::runtime_error("fragmentExpansion with old arguments not implemented\n");
    }
;
@| fragmentExpansion @}

@d Bison rules
@{@%
fragmentNameExpansion
    : %empty
    {
        throw std::runtime_error("fragmentNameExpansion not implemented\n");
    }
@| fragmentNameExpansion @}
