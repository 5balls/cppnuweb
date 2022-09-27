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
\alt AT_AT
\alt <scrap>
\alt <fragment>
\alt AT_SMALL_F
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
    | AT_AT
    {
        $$ = new escapeCharacterDocumentPart($AT_AT);
    }
    | scrap
    {
        throw std::runtime_error("scrap not implemented\n");
    }
    | fragment
    {
        throw std::runtime_error("fragment in nuwebExpression not implemented\n");
    }
    | AT_SMALL_F
    {
        throw std::runtime_error("@@f not implemented\n");
    }
    | NOT_IMPLEMENTED
    {
        throw std::runtime_error($NOT_IMPLEMENTED->m_filename + ":" + std::to_string($NOT_IMPLEMENTED->m_line) + ":" + std::to_string($NOT_IMPLEMENTED->m_column) + " command \"" + $NOT_IMPLEMENTED->m_value + "\" not implemented!\n");
    }
;
@| nuwebExpression @}


\subsubsection{Include file}
Before going further let's define a ``\codecpp\lstinline{class emptyDocumentPart}''. This is a class which will return a empty string for the \TeX{} code. We don't want to have the include files in any form in the final document.

\indexClass{emptyDocumentPart}
@d \classDeclaration{emptyDocumentPart}
@{
public:
    emptyDocumentPart(filePosition* l_filePosition) : documentPart(l_filePosition){
    }
    virtual std::string texUtf8(void) override {
        return "";
    }
@| emptyDocumentPart @}

Treating include files is interesting, because we do it on the lexer level in the function \codecpp\lstinline{include_file()}. Bison does not need to know about much more than that we read a file here i.e. we got the string ``\lstinline{@@i <filename>}'' at some point and from now on Bison will get the tokens from that file.

\indexFlexRule{INCLUDE_FILE}
@d Lexer rule for including files
@{
<INITIAL>@@i[ ][^\n]+ { include_file(); return yy::parser::token::yytokentype::INCLUDE_FILE; }
@| INCLUDE_FILE @}

Token\footnote{\begin{samepage}\noindent Token:@d Bison token definitions
@{%token INCLUDE_FILE
@| INCLUDE_FILE @}\end{samepage}} and type\footnote{\begin{samepage}\noindent Type:@d Bison type definitions
@{%type <m_filePosition> INCLUDE_FILE;
@| INCLUDE_FILE @}\end{samepage}} are defined as usual.

Now let's get to the magic function \codecpp\lstinline{include_file()}:

\indexClassMethod{helpLexer}{include\_file}
@D Implementation of additional helpLexer functions
@{
void include_file(){
    // @xinclude_file_1@x Get filename:
    std::string filename = std::string(yytext, yyleng);
    // @xinclude_file_2@x Remove '@@i '
    filename.erase(filename.begin(), filename.begin()+3);
    // @xinclude_file_3@x Return correct values later:
    if(filenameStack.empty())
        yylvalue->m_filePosition = new filePosition("",lineno(),columno(),lineno_end(),columno_end()); 
    else
        yylvalue->m_filePosition = new filePosition(filenameStack.back(),lineno(),columno(),lineno_end(),columno_end()); 
    // @xinclude_file_4@x Read file:
    nuweb::file* currentFile = new nuweb::file(filename);
    // @xinclude_file_5@x Remember current file:
    filenameStack.push_back(filename);
    // @xinclude_file_6@x Start new matcher:
    utf8Stream = new std::istringstream(currentFile->utf8());
    push_matcher(new_matcher(*utf8Stream));
    if(!has_matcher())
        std::cout << "  Current matcher not usable!\n";
}
@| include_file() @}

This function does the following:
\begin{itemize}
\item [@xinclude_file_1@x] Read the filename from the lex value. This will be \lstinline{"@@i examplefile.w"} at this point.
\item [@xinclude_file_2@x] Extract the filename part by removing the first three characters.
\item [@xinclude_file_3@x] We keep a stack of the list of currently processed filenames here. When we close the file we will pop the filename from the stack, therefore this list is different from the static list of filenames kept in the file class itself. Note that we do some trickery when loading the first file (described next) so we give a file position with an empty string when we have an empty stack.
\item [@xinclude_file_4@x] We read the file using our file class. This class will automatically keep a static list of all objects of this class.
\item [@xinclude_file_5@x] Now we add the file to our list of filenames here.
\item [@xinclude_file_6@x] We ask the lexer to continue reading from our just opened file. Bison will not know about this.
\end{itemize}

Of course once we are finished with reading this file we have to pop the last filename from the stack. This is done in the function \codecpp\lstinline{end_of_file()} called in the @{@<Lexer rule for end of file@>@}. Let's define this function here:

\indexClassMethod{helpLexer}{end\_of\_file}
@D Implementation of additional helpLexer functions
@{
bool end_of_file(){
    // @xend_of_file1@x Return to the previous Matcher:
    pop_matcher();
    // @xend_of_file2@x Delete the istringstream allocated in include_file(): 
    if(utf8Stream){
        delete utf8Stream;
        utf8Stream = nullptr;
    }
    // @xend_of_file3@x Pop the filename of the just closed file from the stack:
    filenameStack.pop_back();
    bool b_stackEmpty = filenameStack.empty();
    // @xend_of_file4@x If the filename stack is empty add an empty filename to behave well:
    if(b_stackEmpty){
        push_matcher(new_matcher(""));
        filenameStack.push_back("");
    }
    // @xend_of_file5@x But still finish the lexer when we reached the end
    // of the bottom file (there is nothing more to parse then):
    return b_stackEmpty;
}
@| end_of_file() @}
\label{methodEndOfFile}

\subsubsection{Escape character}
@d Lexer rule for escape character
@{
<INITIAL,scrapContents,fragmentHeader>[@@][@@] { DTOKEN(AT_AT) }
@}

@d \classDeclaration{escapeCharacterDocumentPart}
@{
private:
    static std::string m_escapementString;
public:
    escapeCharacterDocumentPart(filePosition* l_filePosition) : documentPart(l_filePosition){
    }
    void setEscapeCharacter(const std::string& escape_Character){
        m_escapementString = escape_Character;
    };
    virtual std::string texUtf8(void) override {
        return m_escapementString;
    }
@}

@d \staticDefinitions{escapeCharacterDocumentPart}
@{
std::string nuweb::escapeCharacterDocumentPart::m_escapementString = "@@";
@}



\subsubsection{Fragment}
@d Bison rules
@{
fragment
    : fragmentCommand fragmentName scrap
    {
        throw std::runtime_error("fragment not implemented\n");
    }
    | fragmentCommand fragmentName WHITESPACE scrap
    {
        throw std::runtime_error("fragment whitespace\n");
    }
;
@| fragment @}

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
fragmentName
    : fragmentNamePart
    {
        throw std::runtime_error("fragmentNamePart not implemented!\n");
    }
    | fragmentName fragmentNamePart
    {
        throw std::runtime_error("fragmentName fragmentNamePart not implemented!\n");
    }
;
@| fragmentName @}

@d Bison rules
@{
fragmentNamePart
    : fragmentNameText
    {
        throw std::runtime_error("fragmentNameText not implemented!\n");
    }
    | fragmentNameArgument
    {
        throw std::runtime_error("fragmentNameArgument not implemented!\n");
    }
;
@| fragmentNamePart @}

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
        throw std::runtime_error("AT_AT in fragmentNameText not implemented!\n");
    }
    | TEXT_WITHOUT_AT_OR_WHITESPACE
    {
        throw std::runtime_error("TEXT_WITHOUT_AT_OR_WHITESPACE in fragmentNameText not implemented!\n");
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
@{
fragmentExpansion
    : AT_ANGLE_BRACKET_OPEN fragmentName AT_ANGLE_BRACKET_CLOSE
    {
        throw std::runtime_error("fragmentExpansion not implemented\n");
    }
    | AT_ANGLE_BRACKET_OPEN fragmentName fragmentNameArgumentOld AT_ANGLE_BRACKET_CLOSE
    {
        throw std::runtime_error("fragmentExpansion with old arguments not implemented\n");
    }
;
@| fragmentExpansion @}

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

@d Bison type definitions
@{%type <m_documentPart> scrap
@}

@d \classDeclaration{scrapVerbatim}
@{
public:
    scrapVerbatim(const scrapVerbatim&) = delete;
    scrapVerbatim(scrapVerbatim&& l_scrapVerbatim) : documentPart(std::move(l_scrapVerbatim)) {
    }

    scrapVerbatim(documentPart* l_documentPart) : documentPart(l_documentPart){
    }
    virtual std::string texUtf8(void) override {
        std::stringstream documentLines(documentPart::texUtf8());
        std::string documentLine;
        std::string returnString;
        while(std::getline(documentLines,documentLine))
            returnString += "\\lstinline@@" + documentLine + "@@\n";
        return returnString;
    }
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


