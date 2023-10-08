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
        $l_document->push_back($documentPart);
        $$ = $l_document;
    }
;
@}

Now we have everything needed to define ``\codecpp\lstinline{class document}''. This class takes ownership of any instance of ``\lstinline{class documentPart}'', so we need to delete those instances in the destructor. ``\lstinline{document::addElement}'' adds those instances to an internal list.

\indexClass{document}
@d \classDeclaration{document}
@{
class document : public documentPart {
public:
    document(void) : documentPart() {
    }
    std::string texUtf8(void) const override {
        std::string returnString;
        if(hyperlinksEnabled())
            returnString = R"definitions(\newcommand{\NWtarget}[2]{\hypertarget{#1}{#2}}
\newcommand{\NWlink}[2]{\hyperlink{#1}{#2}}
)definitions";
        else
            returnString = R"definitions(\newcommand{\NWtarget}[2]{#2}
\newcommand{\NWlink}[2]{#2}
)definitions";
        returnString += R"definitions(\newcommand{\NWtxtMacroDefBy}{Fragment defined by}
\newcommand{\NWtxtMacroRefIn}{Fragment referenced in}
\newcommand{\NWtxtMacroNoRef}{Fragment never referenced}
\newcommand{\NWtxtDefBy}{Defined by}
\newcommand{\NWtxtRefIn}{Referenced in}
\newcommand{\NWtxtNoRef}{Not referenced}
\newcommand{\NWtxtFileDefBy}{File defined by}
\newcommand{\NWtxtIdentsUsed}{Uses:}
\newcommand{\NWtxtIdentsNotUsed}{Never used}
\newcommand{\NWtxtIdentsDefed}{Defines:}
\newcommand{\NWsep}{${\diamond}$}
\newcommand{\NWnotglobal}{(not defined globally)}
)definitions";
        if(m_hypperrefOptions.empty())
            returnString += "\\newcommand{\\NWuseHyperlinks}{}\n";
        else
            returnString += "\\newcommand{\\NWuseHyperlinks}{\\usepackage[" + m_hypperrefOptions + "]{hyperref}}\n";
        returnString += documentPart::texUtf8();
        return returnString;
    }
};
@| document addElement @}

\indexClass{document}\indexClassMethod{document}{addElement}

@i reference_documentparts.w
