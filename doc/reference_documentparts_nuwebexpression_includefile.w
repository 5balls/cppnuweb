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

\subsubsection{Include file}
Before going further let's define a ``\codecpp\lstinline{class emptyDocumentPart}''. This is a class which will return a empty string for the \TeX{} code. We don't want to have the include files in any form in the final document.

\indexClass{emptyDocumentPart}
@d \classDeclaration{emptyDocumentPart}
@{@%
class emptyDocumentPart : public documentPart {
public:
    emptyDocumentPart() : documentPart(new filePosition()) {
    }
    emptyDocumentPart(filePosition* l_filePosition) : documentPart(l_filePosition){
    }
    virtual std::string texUtf8(void) const override {
        return "";
    }
};
@| emptyDocumentPart @}

Treating include files is interesting, because we do it on the lexer level in the function \codecpp\lstinline{include_file()}. Bison does not need to know about much more than that we read a file here i.e. we got the string ``\lstinline{@@i <filename>}'' at some point and from now on Bison will get the tokens from that file.

\indexFlexRule{INCLUDE_FILE}
@d Lexer rule for including files
@{@%
@@i[ ][^\n]+[[:space:]]* { include_file(); return yy::parser::token::yytokentype::INCLUDE_FILE; }@| INCLUDE_FILE @}

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
    // @xinclude_file_2b@x Remove whitespace
    std::string whiteSpace = "\n \t\r";
    while(whiteSpace.find(filename.back()) != std::string::npos) filename.pop_back();
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
        throw std::runtime_error("Internal program error, current parser matcher not usable!\n");
}
@| include_file() @}

This function does the following:
\begin{itemize}
\item [@xinclude_file_1@x] Read the filename from the lex value. This will be \lstinline{"@@i examplefile.w"} at this point.
\item [@xinclude_file_2@x] Extract the filename part by removing the first three characters.
\item [@xinclude_file_2b@x] Remove the whitespace at the end of the filename.
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
    if(!filenameStack.empty())
    {
        filenameStack.pop_back();
    }
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


