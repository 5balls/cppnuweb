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

\chapter{Language Reference}

This is an attempt to describe the nuweb grammar in a formal and consistent way. I'm not aware of any previous attempts so there may be and probably are some errors. In a ``webified'' style I attempt to do heavy reordering here for keeping fragments logical together which will go in completely different places\footnote{I will however try to put the repetitive parts in the footnotes so they can be kept close when someone is interested but don't clutter up the text too much.}.

The Bison program is used together with a Flex compatible program to generate a lexer and parser. The Bison code is basically the grammar in Backus-Naur form but with code fragments attached to the rules. To improve readability I write out the (sometimes simplified) Backus-Naur form seperately at the beginning of each section in this chapter. I shorten the Backus-Naur form by notating lists with zero or more elements with a ``*'' and lists with one or more elements with a ``+''.

\section{Document structure}
First, and probably obviously, each nuweb {\synshorts<document>} consists of a list of {\synshorts<documentPart>} and is delimited with an end of file marker\footnote{We don't consider this end of file marker to be part of the document structure, so we don't add it to our abstract syntax tree.}. {\synshorts<documentPart>} can be either {\synshorts<texCode>}, {\synshorts<nuwebExpression>} or {\synshorts<outputFile>}. This section is only about {\synshorts<document>} and the {\synshorts<documentPart>} are treated in \tododocument{Replace with reference to the sections when those sections are written}later sections.

\indexBackusNaur{nuwebAstRoot}\indexBackusNaur{document}\indexBackusNaur{documentPart}\begin{figure}[ht]
\begin{grammar}
<nuwebAstRoot> ::= <document> YYEOF;

<document> ::= <documentPart>*;

<documentPart> ::= <texCode>;
\alt <nuwebExpression>;
\alt <outputFile>;
\end{grammar}
\caption{BNF for nuwebAstRoot, document and documentPart}
\end{figure}

We keep a pointer to the document structure in the Bison parser\footnote{\begin{samepage}Pointer to an object of the document class:\codebisonflex@d Bison parse parameters
@{
%parse-param { document** l_document }
@}\end{samepage}} and define the root of our abstract syntax tree {\synshorts<nuwebAstRoot>}.

\indexBisonRule{nuwebAstRoot}\indexBisonRuleUsesToken{nuwebAstRoot}{YYEOF}@d Bison rules
@{
nuwebAstRoot
    : document YYEOF
    {
        *l_document = $document;
    }
;
@}

\lstinline{YYEOF} is an Flex internal token that is consumed and we don't really care about it. The following Flex rule emits this token with the preprocessor macro \codecpp\lstinline{TOKEN()}

\indexFlexRule{YYEOF}
@D Lexer rule for end of file
@{<<EOF>> { if(end_of_file()) { TOKEN(YYEOF) } }
@}

\codecpp\lstinline{end_of_file()} is discussed later at section \ref{methodEndOfFile} on page \pageref{methodEndOfFile}. We have to tell Flex about the return value of the Flex rule \codebisonflex\lstinline{document}:

\indexBisonType{document}
@d Bison type definitions
@{
%type <m_document> document;
@| document @}

\lstinline{m_document} refers to a part of a union we define for passing values between Flex and Bison. Note that ``\codecpp\lstinline{document*}'' is a C++ class pointer named the same as the Flex rule ``\codebisonflex\lstinline{document}'':

\codecpp
@d Bison union definitions
@{
document* m_document;
@| document @}

We will use the same name for any Flex rule and C++ class wherever we can, because from our view this is the same object. There are some Flex rules which wont need an C++ class though, because they are intermediate steps or the endpoint \codebisonflex\lstinline{nuwebAstRoot}.

Each document consists of a list of ``\lstinline{documentParts}''. We achieve this by matching an empty string to ``\lstinline{document}'' and afterwards match consecutively matched ``\lstinline{documentPart}'' to the right and add them to the list of documentParts in ``\lstinline{document}''.

The \lstinline{%empty} rule is only matched at the beginning and creates a singleton instance of the \codecpp\lstinline{class document}. The second rule is used to add instances of the \lstinline{class documentPart} to this object. We have to refer to the \lstinline{document} rule by an alternative name \lstinline{l_document} because \lstinline{document} is ambiguous here. \lstinline{class documentPart} is defined in the next sections.

\indexBisonRule{document}
@d Bison rules
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

Now we have everything needed to define ``\codecpp\lstinline{class document}''. This class takes ownership of any instance of ``\lstinline{class documentPart}'', so we need to delete those instances in the destructor. ``\lstinline{document::addElement}'' adds those instances to an internal list.

@d \classDeclaration{document}
@{
private:
    std::vector<documentPart*> m_documentParts;
public:
    ~document(void){
        for(auto* documentPart: m_documentParts)
            delete documentPart;
        m_documentParts.clear();
    }
    void addElement(documentPart* l_documentPart){
        m_documentParts.push_back(l_documentPart);
    }
@| document addElement @}\indexClass{document}\indexClassMethod{document}{addElement}

\section{Document parts}
We have to keep track of the filename and the range we refer to when parsing our document, so let's define a structure for that:

\indexStructure{filePosition}
@d C++ structure definitions in namespace nuweb
@{
struct filePosition {
    filePosition(const std::string& filename,
            unsigned int line, unsigned int column,
            unsigned int line_end, unsigned int column_end):
        m_filename(filename),
        m_line(line), m_column(column),
        m_line_end(line_end), m_column_end(column_end){};
    std::string m_filename;
    unsigned int m_line;
    unsigned int m_column;
    unsigned int m_line_end;
    unsigned int m_column_end;
};
@| filePosition @}

We want to keep this outside of a class, so we can use this as a return type for the lexer as well. The lexer should not know about the higher structures of the document.

As mentioned in the previous section, a ``\codebisonflex\lstinline{documentPart}'' can be ``\lstinline{texCode}'', a ``\lstinline{nuwebExpression}'' or an ``\lstinline{outputFile}'':
\indexBisonRule{documentPart}
@d Bison rules
@{
documentPart
    : texCode
    {
        $$ = $texCode;
    }
    | nuwebExpression
    | outputFile
;
@| documentPart @}

We add the documentPart to our union and define a type based on that union element again:

\indexBisonType{documentPart}
@d Bison type definitions
@{
%type <m_documentPart> documentPart;
@| documentPart @}

\codecpp
@d Bison union definitions
@{
documentPart* m_documentPart;
@| documentPart @}

This is all we need to define our ``\lstinline{class documentPart}''.

\indexClass{documentPart}\indexClassBaseOf{documentPart}{outputFile}\indexClassBaseOf{documentPart}{emptyDocumentPart}
@d \classDeclaration{documentPart}
@{@%
class documentPart: public std::vector<documentPart*> {
private:
    filePosition* m_filePosition = nullptr;
public:
    documentPart(const documentPart&) = delete;
    documentPart(void) : std::vector<documentPart*>({}) {
    }
    documentPart(documentPart&& l_documentPart) : m_filePosition(l_documentPart.m_filePosition), std::vector<documentPart*>(std::move(l_documentPart)) {
    }
    documentPart(documentPart* l_documentPart) : documentPart(std::move(*l_documentPart)){
    }
    documentPart(filePosition* l_filePosition) : m_filePosition(l_filePosition){
        //std::cout << "documentPart[" << m_filePosition.m_filename << ":" << m_filePosition.m_line << "," << m_filePosition.m_column << "|" << m_filePosition.m_line_end << "," << m_filePosition.m_column_end << ").";
    }
    virtual std::string utf8();
    virtual std::string texUtf8();
@| documentPart utf8 texUtf8 @}

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
    | AT_LARGE_D
    {
        throw std::runtime_error("large d\n");
    }
    | AT_SMALL_Q
;
@| fragmentCommand @}

@d Bison rules
@{
fragmentName
    : fragmentNamePart
    | fragmentName fragmentNamePart
;
@| fragmentName @}

@d Bison rules
@{
fragmentNamePart
    : fragmentNameText
    | fragmentNameArgument
;
@| fragmentNamePart @}

\indexBisonRuleUsesToken{fragmentNameArgument}{TEXT\_WITHOUT\_AT}\indexBisonRuleUsesToken{fragmentNameArgument}{AT\_TICK}\indexBisonRuleUsesToken{fragmentNameArgument}{TEXT\_WITHOUT\_AT\_OR\_WHITESPACE}
@d Bison rules
@{
fragmentNameArgument
    : AT_TICK AT_TICK
    | AT_TICK TEXT_WITHOUT_AT AT_TICK
    | AT_TICK TEXT_WITHOUT_AT_OR_WHITESPACE AT_TICK
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
;
@| fragmentNameArgumentOld @}

@d Bison rules
@{
commaSeparatedFragmentArguments
    : commaSeparatedFragmentArgument
    | commaSeparatedFragmentArguments AT_AT commaSeparatedFragmentArgument
;
@| commaSeparatedFragmentArguments @}

\indexBisonRuleUsesToken{commaSeparatedFragmentArgument}{TEXT\_WITHOUT\_AT}
@d Bison rules
@{
commaSeparatedFragmentArgument
    : TEXT_WITHOUT_AT
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

\subsection{Output file}
@d Bison rules
@{
outputFile
    : outputCommand WHITESPACE outputFilename WHITESPACE scrap
    {
        throw std::runtime_error("outputCommand\n");
    }
    | outputCommand WHITESPACE outputFilename WHITESPACE outputFlags WHITESPACE scrap
    {
        throw std::runtime_error("outputCommand with filename <hidden in file class somewhere> and flags\n");
    }
;
@| outputFile @}

@d Bison type definitions
@{%type <m_filePosition> outputFilename;
@| outputFilename @}

@d Bison rules
@{
outputCommand
    : AT_SMALL_O
    | AT_LARGE_O
;
@| outputCommand @}

@d Bison rules
@{
outputFilename
    : TEXT_WITHOUT_AT_OR_WHITESPACE
;
@| outputFilename @}

@d Bison rules
@{
outputFlags
    : MINUS_D
;
@| outputFlags @}

\indexClass{outputFile}\todoimplement{Output function for file contents}
@d \classDeclaration{outputFile}
@{
private:
    std::string m_filename;
public:
    outputFile(filePosition* l_filePosition, std::string filename) : documentPart(l_filePosition), m_filename(filename){
        //std::cout << "outputFile";
        std::cout << "outputFile(" << m_filename << ")\n";
    }
@| outputFile @}
