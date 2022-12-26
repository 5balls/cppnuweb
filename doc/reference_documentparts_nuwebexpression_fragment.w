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
@<\bisonRule{fragmentNamePartReference}@>
@<\bisonRule{fragmentNameArgument}@>
@<\bisonRule{fragmentNameArgumentReference}@>
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
@<\bisonTypeDefinition{fragmentNameArgument}@>
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
            case fragmentType::DEFINITION_GLOBAL:
                {
                    fragmentDefinition* globalFragment = new fragmentDefinition($fragmentNameDefinition, $scrap);
                    globalFragment->setGlobal();
                    $$ = globalFragment;
                }
                break;
            case fragmentType::DEFINITION_PAGEBREAK:
                $$ = new fragmentDefinition($fragmentNameDefinition, $scrap, true);
                break;
            case fragmentType::DEFINITION_PAGEBREAK_GLOBAL:
                {
                    fragmentDefinition* globalFragment = new fragmentDefinition($fragmentNameDefinition, $scrap, true);
                    globalFragment->setGlobal();
                    $$ = globalFragment;
                }
                break;
            case fragmentType::QUOTED:
                $$ = new fragmentQuoted($fragmentNameDefinition, $scrap);
                break;
            case fragmentType::QUOTED_GLOBAL:
                {
                    fragmentDefinition* globalFragment = new fragmentQuoted($fragmentNameDefinition, $scrap);
                    globalFragment->setGlobal();
                    $$ = globalFragment;
                }
                break;
            case fragmentType::QUOTED_PAGEBREAK:
                $$ = new fragmentQuoted($fragmentNameDefinition, $scrap, true);
                break;
            case fragmentType::QUOTED_PAGEBREAK_GLOBAL:
                {
                    fragmentDefinition* globalFragment = new fragmentQuoted($fragmentNameDefinition, $scrap, true);
                    globalFragment->setGlobal();
                    $$ = globalFragment;
                }
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

@d \bisonRule{fragmentCommand}
@{
fragmentCommand
    : AT_SMALL_D
    {
        $$ = fragmentType::DEFINITION;
    }
    | AT_SMALL_D_PLUS
    {
        $$ = fragmentType::DEFINITION_GLOBAL;
    }
    | AT_LARGE_D
    {
        $$ = fragmentType::DEFINITION_PAGEBREAK;
    }
    | AT_LARGE_D_PLUS
    {
        $$ = fragmentType::DEFINITION_PAGEBREAK_GLOBAL;
    }
    | AT_SMALL_Q
    {
        $$ = fragmentType::QUOTED;
    }
    | AT_SMALL_Q_PLUS

    {
        $$ = fragmentType::QUOTED_GLOBAL;
    }
    | AT_LARGE_Q
    {
        $$ = fragmentType::QUOTED_PAGEBREAK;
    }
    | AT_LARGE_Q_PLUS
    {
        $$ = fragmentType::QUOTED_PAGEBREAK_GLOBAL;
    }
;
@| fragmentCommand @}

We define a simple enum class type\footnote{Type:@d C++ enum class definitions in namespace nuweb
@{@%
enum class fragmentType {
    OUTPUT_FILE,
    OUTPUT_FILE_PAGEBREAK,
    DEFINITION,
    DEFINITION_GLOBAL,
    DEFINITION_PAGEBREAK,
    DEFINITION_PAGEBREAK_GLOBAL,
    QUOTED,
    QUOTED_GLOBAL,
    QUOTED_PAGEBREAK,
    QUOTED_PAGEBREAK_GLOBAL
};
@| fragmentType @}} for fragmentCommand and the tokens\footnote{Tokens:@d Bison token definitions
@{@%
%token AT_SMALL_D AT_SMALL_D_PLUS AT_LARGE_D AT_LARGE_D_PLUS AT_SMALL_Q AT_SMALL_Q_PLUS AT_LARGE_Q AT_LARGE_Q_PLUS
@| AT_SMALL_D AT_SMALL_D_PLUS AT_LARGE_D AT_LARGE_D_PLUS AT_SMALL_Q AT_SMALL_Q_PLUS AT_LARGE_Q AT_LARGE_Q_PLUS @}}, the type\footnote{Type:@d \bisonTypeDefinition{fragmentCommand}
@{@%
%type <m_fragmentType> fragmentCommand
@| fragmentCommand @}} and the union\footnote{Union:@d Bison union definitions
@{@%
enum fragmentType m_fragmentType;
@| m_fragmentType @}}. We have some simple rules for the fragment commands:
@d Lexer rules for fragment commands
@{@%
<INITIAL>@@d[ ] { start(fragmentHeader); TOKEN(AT_SMALL_D) }
<INITIAL>@@d\+[ ] { start(fragmentHeader); TOKEN(AT_SMALL_D_PLUS) }
<INITIAL>@@D[ ] { start(fragmentHeader); TOKEN(AT_LARGE_D) }
<INITIAL>@@D\+[ ] { start(fragmentHeader); TOKEN(AT_LARGE_D_PLUS) }
<INITIAL>@@q[ ] { start(fragmentHeader); TOKEN(AT_SMALL_Q) }
<INITIAL>@@q\+[ ] { start(fragmentHeader); TOKEN(AT_SMALL_Q_PLUS) }
<INITIAL>@@Q[ ] { start(fragmentHeader); TOKEN(AT_LARGE_Q) }
<INITIAL>@@Q\+[ ] { start(fragmentHeader); TOKEN(AT_LARGE_Q_PLUS) }
@| AT_SMALL_D AT_SMALL_D_PLUS AT_LARGE_D AT_LARGE_D_PLUS AT_SMALL_Q AT_SMALL_Q_PLUS AT_LARGE_Q AT_LARGE_Q_PLUS @}

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

@d \bisonRule{fragmentNameReference}
@{
fragmentNameDefinitionReference
    : fragmentNamePartReference
    {
        $$ = new documentPart();
        $$->push_back($fragmentNamePartReference);
    }
    | fragmentNameDefinitionReference[l_fragmentNameReference] fragmentNamePartReference
    {
        $l_fragmentNameReference->push_back($fragmentNamePartReference);
        $$ = $l_fragmentNameReference;
    }
;
@| fragmentNameDefinitionReference @}


@d \bisonTypeDefinition{fragmentNameDefinition}
@{@%
%type <m_documentPart> fragmentNameDefinition
%type <m_documentPart> fragmentNameDefinitionReference
@| fragmentNameDefinition fragmentNameDefinitionReference @}

@d \bisonRule{fragmentNamePartDefinition}
@{
fragmentNamePartDefinition
    : fragmentNameText
    {
        $$ = new fragmentNamePartText($fragmentNameText);
    }
    | fragmentNameArgument
    {
        $$ = $fragmentNameArgument;
    }
;
@| fragmentNamePartDefinition @}

@d \bisonRule{fragmentNamePartReference}
@{
fragmentNamePartReference
    : fragmentNameText
    {
        $$ = new fragmentNamePartText($fragmentNameText);
    }
    | fragmentNameArgumentReference
    {
        $$ = $fragmentNameArgumentReference;
    }
;
@| fragmentNamePartReference @}

@d \bisonTypeDefinition{fragmentNamePartDefinition}
@{@%
%type <m_documentPart> fragmentNamePartDefinition
%type <m_documentPart> fragmentNamePartReference
@| fragmentNamePartDefinition fragmentNamePartReference @}

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
        $$ = new fragmentNamePartArgumentString(new documentPart($TEXT_WITHOUT_AT_OR_NEWLINE));
    }
    | AT_ANGLE_BRACKET_OPEN fragmentNameReference AT_ANGLE_BRACKET_CLOSE
    {
        $fragmentNameReference->setFilePosition($AT_ANGLE_BRACKET_OPEN);
        $$ = new fragmentNamePartArgumentFragmentName($fragmentNameReference);
    }
    | AT_ANGLE_BRACKET_OPEN_PLUS fragmentNameReference AT_ANGLE_BRACKET_CLOSE
    {
        $fragmentNameReference->setFilePosition($AT_ANGLE_BRACKET_OPEN_PLUS);
        fragmentNamePartArgumentFragmentName* globalFragmentName = new fragmentNamePartArgumentFragmentName($fragmentNameReference);
        globalFragmentName->setGlobal();
        $$ = globalFragmentName;
    }
;
@| fragmentNameArgument @}

@d \bisonRule{fragmentNameArgumentReference}
@{
fragmentNameArgumentReference
    : AT_TICK AT_TICK
    {
        throw std::runtime_error("AT_TICK AT_TICK not implemented!\n");
    }
    | AT_TICK TEXT_WITHOUT_AT_OR_NEWLINE AT_TICK
    {
        $$ = new fragmentNamePartArgumentString(new documentPart($TEXT_WITHOUT_AT_OR_NEWLINE));
    }
    | AT_ANGLE_BRACKET_OPEN fragmentNameReference AT_ANGLE_BRACKET_CLOSE
    {
        $fragmentNameReference->setFilePosition($AT_ANGLE_BRACKET_OPEN);
        $$ = new fragmentNamePartArgumentFragmentName($fragmentNameReference);
    }
    | AT_ANGLE_BRACKET_OPEN_PLUS fragmentNameReference AT_ANGLE_BRACKET_CLOSE
    {
        $fragmentNameReference->setFilePosition($AT_ANGLE_BRACKET_OPEN_PLUS);
        fragmentNamePartArgumentFragmentName* globalFragmentName = new fragmentNamePartArgumentFragmentName($fragmentNameReference);
        globalFragmentName->setGlobal();
        $$ = globalFragmentName;
    }
    | AT_CURLY_BRACKET_OPEN scrapContents AT_CURLY_BRACKET_CLOSE
    {
        $$ = new scrapVerbatimArgument($scrapContents);
    }
;
@| fragmentNameArgumentReference @}


@d Bison token definitions
@{@%
%token AT_ANGLE_BRACKET_OPEN AT_ANGLE_BRACKET_CLOSE AT_ANGLE_BRACKET_OPEN_PLUS 
@| AT_ANGLE_BRACKET_OPEN AT_ANGLE_BRACKET_CLOSE AT_ANGLE_BRACKET_OPEN_PLUS @}

@d \bisonTypeDefinition{fragmentNameArgument}
@{@%
%type <m_documentPart> fragmentNameArgument
%type <m_documentPart> fragmentNameArgumentReference
@| fragmentNameArgument fragmentNameArgumentReference @}

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
        $$->setFilePosition($AT_ANGLE_BRACKET_OPEN);
    }
    | AT_ANGLE_BRACKET_OPEN_PLUS fragmentNameReference AT_ANGLE_BRACKET_CLOSE
    {
        $$ = $fragmentNameReference;
        $$->setFilePosition($AT_ANGLE_BRACKET_OPEN_PLUS);
        $$->setGlobal();
    }
    | AT_ANGLE_BRACKET_OPEN fragmentNameReference fragmentNameArgumentOld AT_ANGLE_BRACKET_CLOSE
    {
        throw std::runtime_error("fragmentReference with old arguments not implemented\n");
    }
    | AT_ANGLE_BRACKET_OPEN_PLUS fragmentNameReference fragmentNameArgumentOld AT_ANGLE_BRACKET_CLOSE
    {
        throw std::runtime_error("fragmentReference with old arguments not implemented\n");
    }
;
@| fragmentReference @}

@d Lexer rules for fragment headers and references
@{@%
<scrapContents,fragmentReference>@@< { start(fragmentReference); m_fragmentReferenceDepth++; TOKEN(AT_ANGLE_BRACKET_OPEN) }
<scrapContents,fragmentReference>@@<\+[ ] { start(fragmentReference); m_fragmentReferenceDepth++; TOKEN(AT_ANGLE_BRACKET_OPEN_PLUS) }
<fragmentReference>@@> { m_fragmentReferenceDepth--; if(m_fragmentReferenceDepth == 0) start(scrapContents); TOKEN(AT_ANGLE_BRACKET_CLOSE) }
<INITIAL>@@< { start(fragmentReferenceExpanded); TOKEN(AT_ANGLE_BRACKET_OPEN) }
<fragmentReferenceExpanded>@@> { start(INITIAL); TOKEN(AT_ANGLE_BRACKET_CLOSE) }
<fragmentHeader,fragmentReference,fragmentReferenceExpanded>@@' {  TOKEN(AT_TICK) }
<fragmentHeader,scrapContents,scrapContentsInsideFragmentReference>@@[1-9] { INTTOKEN(AT_NUMBER, std::stoi(std::string(yytext+1, yyleng-1))) }
@}

@d \bisonRule{fragmentNameReference}
@{@%
fragmentNameReference
    : fragmentNameDefinitionReference
    {
        $$ = new fragmentReference($fragmentNameDefinitionReference);
    }
@| fragmentNameReference @}

@d Bison union definitions
@{@%
fragmentReference* m_fragmentReference;
@}

@d \bisonTypeDefinition{fragmentNameReference}
@{@%
%type <m_fragmentReference> fragmentNameReference
%type <m_filePosition> AT_ANGLE_BRACKET_OPEN
%type <m_filePosition> AT_ANGLE_BRACKET_OPEN_PLUS
@}

@d \bisonTypeDefinition{fragmentReference}
@{@%
%type <m_fragmentReference> fragmentReference
@}

