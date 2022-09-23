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

\subsection{Glue code between Bison and Flex}
\codecpp
Apparently there is some glue code needed so that Bison and Flex can talk to each other when using C++ for both. It seems it is easier if at least Flex is C, but I want to have only C++ code here. The code between \%\{ and \%\} is included at the beginning of the generated file. \lstinline{"parser.hpp"} is a header generated by Bison via the cmake rules and will contain the token definitions for example which are generated by the \verb|%token| commands following in the bison file below.

\codebisonflex
@O ../src/nuweb.y
@{
%code requires {
    #include <iostream>
    #include "parser.hpp"
    #include "../../src/ast.h"
    using namespace nuweb;
    class helpLexer;
}
@}

\codecpp
Here we need to fix a problem. Bison wants to call a function of type ``\lstinline{int yylex(yy::parser::semantic_type* yylvalue);}'' while Flex provides a method of type ``\lstinline{int yyFlexLexer::yylex(void);}''. We create a new ``\lstinline{class helpLexer : public yyFlexLexer}'' and store the value in this class. We provide a wrapper function here for Bison which has an additional argument ``\lstinline{helpLexer* lexer}'' to pass a pointer to our class object.

@O ../src/nuweb.y
@{
%code {
    #include "../../src/helplexer.h"
    int yylex(yy::parser::semantic_type* yylvalue, helpLexer* lexer){
        return lexer->yylex(yylvalue);
    };
    void yy::parser::error(const std::string& s){
        /* TODO Throw error here */
        std::cout << "ERROR: " <<s;
    };
}
@}

We need to tell Bison about this new argument of course:

\codebisonflex
@d Flex parameters
@{
%lex-param { helpLexer* lexer }
@}

\codecpp
We also need to pass a pointer to this \lstinline{helpLexer} object in the constructor of the ``\lstinline{class yy::parser}'' which is generated for us by Bison.

\codebisonflex
@d Parse parameters
@{
%parse-param { helpLexer* lexer }
%parse-param { document** l_document }
@}

So let's go ahead and write this helper class.

\codecpp
@O ../src/helplexer.h -d
@{
@<Start of @'HELPLEXER@' header@>

#if defined(REFLEX)
#  if !defined(REFLEX_OPTION_header_file)
#    include "lex.yy.h"
#  endif
#else
#  if !defined(yyFlexLexerOnce)
#    include <FlexLexer.h>
#  endif
#endif

#include "parser.hpp"
#include "../../src/file.h"
#include <iostream>

@<Start of class @'helpLexer@' base @'yyFlexLexer@'@>
private:
    yy::parser::semantic_type* yylvalue;
    std::vector<std::string> filenameStack;
    std::istringstream* utf8Stream;
    int yylex(void);
    void include_file(){
        // Get filename:
        std::string filename = std::string(yytext, yyleng);
        // Remove '@@i '
        filename.erase(filename.begin(), filename.begin()+3);
        // Return correct values later:
        if(filenameStack.empty())
            yylvalue->m_stringValue = new filePositionWithString("",lineno(),columno(),lineno_end(),columno_end(),filename); 
        else
            yylvalue->m_stringValue = new filePositionWithString(filenameStack.back(),lineno(),columno(),lineno_end(),columno_end(),filename); 
        // Read file:
        nuweb::file* currentFile = new nuweb::file(filename);
        // Remember current file:
        filenameStack.push_back(filename);
        // Start new matcher:
        utf8Stream = new std::istringstream(currentFile->utf8());
        push_matcher(new_matcher(*utf8Stream));
        if(!has_matcher())
            std::cout << "  Current matcher not usable!\n";
    }
    bool end_of_file(){
        pop_matcher();
        if(utf8Stream){
            delete utf8Stream;
            utf8Stream = nullptr;
        }
        filenameStack.pop_back();
        bool b_stackEmpty = filenameStack.empty();
        if(b_stackEmpty){
            push_matcher(new_matcher(""));
            filenameStack.push_back("");
        }
        return b_stackEmpty;
    }
public:

#if defined(REFLEX)
    helpLexer(std::istream* inputStream, std::ostream* outputStream);
    helpLexer(std::string inputString);
#else
    helpLexer(std::istream& inputStream, std::ostream& outputStream);
#endif
    int yylex(yy::parser::semantic_type* yylvalue);
@<End of class and header@>
@}

We need to still define the constructor ``\lstinline{helpLexer::helpLexer(std::istream&, std::ostream&);}'' and ``\lstinline{int helpLexer::yylex(yy::parser::semantic_type* yylvalue);}'' but let's not use a seperate file for this but put it at the end of the Bison file later:

@d Function definition for int yylex(yy::parser::semantic_type* yylvalue);
@{
/*int helpLexer::yylex(void){
    // Should never be called
    return 0;
}*/
#if defined(REFLEX)
helpLexer::helpLexer(std::istream* inputStream, std::ostream* outputStream) : yyFlexLexer(inputStream, outputStream) {
}
helpLexer::helpLexer(std::string inputString) : yyFlexLexer(inputString) {
}

#else
helpLexer::helpLexer(std::istream& inputStream, std::ostream& outputStream) : yyFlexLexer(inputStream, outputStream) {
}
#endif

int helpLexer::yylex(yy::parser::semantic_type* yylvalue){
    this->yylvalue = yylvalue;
    return yylex();
}



@}


