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

\subsection{Nuweb expression}
A ``\lstinline{nuwebExpression}'' is basically every nuweb command\footnote{Anything that starts with an ``@@''} except for the output file commands ``@@o'' and ``@@O'' which have to be treated specially.

\indexBackusNaur{nuwebExpression}\begin{figure}[ht]
\begin{grammar}
<nuwebExpression> ::= INCLUDE_FILE
\alt INCLUDE_FILE_ACCESS_ERROR
\alt AT_AT
\alt <scrap>
\alt <fragmentDefinition>
\alt <fragmentReference>
\alt AT_SMALL_F
\alt AT_SMALL_M
\alt AT_SMALL_M_PLUS
\alt AT_SMALL_V
\alt AT_SMALL_S
\alt AT_LARGE_S
\alt NOT_IMPLEMENTED
\end{grammar}
\caption{BNF for nuwebExpression}
\end{figure}

\indexBisonRule{nuwebExpression}\indexBisonRuleUsesToken{nuwebExpression}{INCLUDE\_FILE}\indexBisonRuleUsesToken{nuwebExpression}{AT\_SMALL\_F}\indexBisonRuleUsesToken{nuwebExpression}{NOT\_IMPLEMENTED}
@D Bison rules
@{
nuwebExpression
    : INCLUDE_FILE
    {
        $$ = new emptyDocumentPart($INCLUDE_FILE);
    }
    | INCLUDE_FILE_ACCESS_ERROR
    {
        $$ = new emptyDocumentPart($INCLUDE_FILE_ACCESS_ERROR);
    }
    | AT_AT
    {
        $$ = new escapeCharacterDocumentPart($AT_AT);
    }
    | scrap
    {
        $$ = new scrapStandalone($scrap);
    }
    | fragmentDefinition
    {
        $$ = $fragmentDefinition;
    }
    | fragmentReference
    {
        $fragmentReference->setExpandReference(true);
        $$ = $fragmentReference;
    }
    | AT_SMALL_F
    {
        throw std::runtime_error("@@f not implemented\n");
    }
    | AT_SMALL_M
    {
        $$ = new indexFragmentNames($AT_SMALL_M);
    }
    | AT_SMALL_M_PLUS
    {
        indexFragmentNames* globalIndex = new indexFragmentNames($AT_SMALL_M_PLUS);
        globalIndex->setGlobal();
        $$ = globalIndex;
    }
    | AT_SMALL_V
    {
        $$ = new versionString($AT_SMALL_V);
    }
    | AT_SMALL_S
    {
        $$ = new emptyDocumentPart();
        documentPart::newSection();
    }
    | AT_LARGE_S
    {
        $$ = new emptyDocumentPart();
        documentPart::closeSection();
    }
    | crossReference
    {
        $$ = $crossReference;
    }
    | AT_SMALL_C TEXT_WITHOUT_AT
    {
        $$ = new blockComment($TEXT_WITHOUT_AT);
    }
    | NOT_IMPLEMENTED
    {
        throw std::runtime_error($NOT_IMPLEMENTED->m_filename + ":" + std::to_string($NOT_IMPLEMENTED->m_line) + ":" + std::to_string($NOT_IMPLEMENTED->m_column) + " command \"" + $NOT_IMPLEMENTED->m_value + "\" not implemented!\n");
    }
;
@| nuwebExpression @}


@d Lexer rules for regular nuweb commands
@{<INITIAL>@@m { TOKEN(AT_SMALL_M) }
<INITIAL>@@m\+ { TOKEN(AT_SMALL_M_PLUS) }
<INITIAL,scrapContents>@@v { TOKEN(AT_SMALL_V) } 
<INITIAL>@@s { TOKEN(AT_SMALL_S) } 
<INITIAL>@@S { TOKEN(AT_LARGE_S) } 
@| AT_SMALL_M AT_SMALL_M_PLUS AT_SMALL_V AT_SMALL_S AT_LARGE_S @}

@d Bison token definitions
@{%token AT_SMALL_M
%token AT_SMALL_M_PLUS
%token AT_SMALL_V
%token AT_SMALL_S
%token AT_LARGE_S
@| AT_SMALL_M AT_SMALL_M_PLUS AT_SMALL_V AT_SMALL_S AT_LARGE_S @}

@d Bison type definitions
@{%type <m_filePosition> AT_SMALL_M;
%type <m_filePosition> AT_SMALL_M_PLUS;
%type <m_filePosition> AT_SMALL_V;
%type <m_filePosition> AT_SMALL_S;
%type <m_filePosition> AT_LARGE_S;
@}

@i reference_documentparts_nuwebexpression_includefile.w

@i reference_documentparts_nuwebexpression_escapecharacter.w

@i reference_documentparts_nuwebexpression_fragment.w

@i reference_documentparts_nuwebexpression_scrap.w

@i reference_documentparts_nuwebexpression_crossreference.w

@i reference_documentparts_nuwebexpression_blockcomment.w
