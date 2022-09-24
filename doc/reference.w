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

This is an attempt to describe the nuweb grammar in a formal and consistent way. I'm not aware of any previous attempts so there may be and probably are some errors. In a ``webified'' style I attempt to do heavy reordering here for keeping fragments logical together which will go in completely different places.

The Bison program is used together with a Flex compatible program to generate a lexer and parser. The Bison code is basically the grammar in Backus-Naur form but with code fragments attached to the rules. To improve readability I write out the (sometimes simplified) Backus-Naur form seperately at the beginning of each section in this chapter.

\section{Document structure}
The first section is about an implementation detail and can be probably skipped, if you are more interested in the language. Anyway, it needs to be done.

\subsection{General structure}
First, and probably obviously, each nuweb document ends with a end of file marker (which we don't consider part of \lstinline{document}):

\indexBackusNaur{nuwebAstRoot}\begin{figure}[ht]
\begin{grammar}
<nuwebAstRoot> ::= <document> YYEOF;
\end{grammar}
\caption{BNF for nuwebAstRoot}
\end{figure}

We keep a pointer to the document structure in Bison

\codebisonflex
@D Bison parse parameters
@{
%parse-param { document** l_document }
@}

and define the root of our abstract syntax tree as such:

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
@{
<<EOF>> { if(end_of_file()) { TOKEN(YYEOF) } }
@}

\codecpp\lstinline{end_of_file()} is discussed later. We have to tell Flex about the return value of the Flex rule \codebisonflex\lstinline{document}:

@d Flex type definitions
@{
%type <m_document> document;
@}

\lstinline{m_document} refers to a part of a union we define for passing values between Flex and Bison. Note that ``\codecpp\lstinline{document*}'' is a C++ class pointer named the same as the Flex rule ``\codebisonflex\lstinline{document}'':

\codecpp
@d Lex union definitions
@{
document* m_document;
@}

We will use the same name for any Flex rule and C++ class wherever we can, because from our view this is the same object. There are some Flex rules which wont need an C++ class though, because they are intermediate steps or the endpoint \codebisonflex\lstinline{nuwebAstRoot}.

Each document consists of a list of ``\lstinline{documentParts}''. We achieve this by matching an empty string to ``\lstinline{document}'' and afterwards match consecutively matched ``\lstinline{documentPart}'' to the right and add them to the list of documentParts in ``\lstinline{document}''.

\indexBackusNaur{document}\begin{figure}[ht]
\begin{grammar}
<document> ::= $\epsilon$
\alt <document> <documentPart>;
\end{grammar}
\caption{BNF for document}
\end{figure}

The \lstinline{%empty} rule is only matched at the beginning and creates a singleton instance of the \codecpp\lstinline{class document}. The second rule is used to add instances of the \lstinline{class documentPart} to this object. \lstinline{class documentPart} is defined in the next section.

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

@O ../src/document.h -d
@{
@<Start of @'DOCUMENT@' header@>

#include "documentPart.h"

@<Start of class @'document@' in namespace @'nuweb@'@>
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
@<End of class, namespace and header@>
@}\indexHeader{DOCUMENT}\indexClass{document}\indexClassMethod{document}{addElement}

\subsection{Document parts}
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
@}

We want to keep this outside of a class, so we can use this as a return type for the lexer as well. The lexer does not know about the higher structures of the document. This is all we need to define our ``\lstinline{class documentPart}''.

\indexHeader{DOCUMENT\_PART}\indexClass{documentPart}\indexClassBaseOf{documentPart}{texCode}\indexClassBaseOf{documentPart}{includeFile}\indexClassBaseOf{documentPart}{outputFile}
@O ../src/documentPart.h -d
@{
@<Start of @'DOCUMENT_PART@' header@>

#include "definitions.h"
#include "file.h"

@<Start of class @'documentPart@' in namespace @'nuweb@'@>
private:
    filePosition m_filePosition;
public:
    documentPart(const filePosition& l_filePosition) : m_filePosition(l_filePosition){
        std::cout << "documentPart[" << m_filePosition.m_filename << ":" << m_filePosition.m_line << "," << m_filePosition.m_column << "|" << m_filePosition.m_line_end << "," << m_filePosition.m_column_end << ").";
    };
    std::string texUtf8(){
        file* l_file = file::byName(m_filePosition.m_filename);
        return l_file->utf8({{m_filePosition.m_line,m_filePosition.m_column},
                {m_filePosition.m_line_end,m_filePosition.m_column_end}});
    };
@<End of class@>
@}

A \lstinline{documentPart} can be one of three types:

\indexBackusNaur{documentPart}\begin{figure}[ht]
\begin{grammar}
<documentPart> ::= <texCode>;
\alt <nuwebExpression>;
\alt <outputFile>;
\end{grammar}
\caption{BNF for documentPart}
\end{figure}

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
@}

\indexBisonRule{texCode}\indexBisonRuleUsesToken{texCode}{TEXT\_WITHOUT\_AT}\indexBisonRuleUsesToken{texCode}{WHITESPACE}\indexBisonRuleUsesToken{texCode}{TEXT\_WITHOUT\_AT\_OR\_WHITESPACE}
@d Bison rules
@{
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
@}

We have the following Flex rules for this

\indexFlexRule{WHITESPACE}\indexFlexRule{TEXT\_WITHOUT\_AT\_OR\_WHITESPACE}\indexFlexRule{TEXT\_WITHOUT\_AT}
@d Lexer rules for text handling
@{
<outputFileHeader>[[:space:]]+  { DSTRINGTOKEN(WHITESPACE) }
<outputFileHeader>[^@@[:space:]]+ { DSTRINGTOKEN(TEXT_WITHOUT_AT_OR_WHITESPACE) }
<INITIAL,scrapContents,fragmentHeader,fragmentExpansion>[^@@]+ { DSTRINGTOKEN(TEXT_WITHOUT_AT) }
@}

\indexBisonRule{nuwebExpression}\indexBisonRuleUsesToken{nuwebExpression}{AT\_AT}\indexBisonRuleUsesToken{nuwebExpression}{AT\_SMALL\_F}\indexBisonRuleUsesToken{nuwebExpression}{NOT\_IMPLEMENTED}
@d Bison rules
@{
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

\indexClass{texCode}
@O ../src/documentPart.h -d
@{
@<Start of class @'texCode@' base @'documentPart@'@>
private:
    std::string m_contents;
public:
    texCode(const filePositionWithString& l_filePosition) : documentPart(filePosition(l_filePosition.m_filename, l_filePosition.m_line, l_filePosition.m_column, l_filePosition.m_line_end, l_filePosition.m_column_end)), m_contents(l_filePosition.m_value){
        std::cout << "texCode\n";
        //std::cout << "texCode(" << m_contents << ")";
    }
@<End of class@>
@}

\indexClass{includeFile}
@O ../src/documentPart.h -d
@{
@<Start of class @'includeFile@' base @'documentPart@'@>
private:
    std::string m_filename;
public:
    includeFile(const filePositionWithString& l_filePosition) : documentPart(filePosition(l_filePosition.m_filename, l_filePosition.m_line, l_filePosition.m_column, l_filePosition.m_line_end, l_filePosition.m_column_end)), m_filename(l_filePosition.m_value){
        //std::cout << "includeFile";
        std::cout << "includeFile(" << m_filename << ")\n";
    }
@<End of class@>
@}

\indexClass{outputFile}
@O ../src/documentPart.h -d
@{
@<Start of class @'outputFile@' base @'documentPart@'@>
private:
    std::string m_filename;
public:
    outputFile(const filePosition& l_filePosition, std::string filename) : documentPart(l_filePosition), m_filename(filename){
        //std::cout << "outputFile";
        std::cout << "outputFile(" << m_filename << ")\n";
    }
@<End of class, namespace and header@>
@}
