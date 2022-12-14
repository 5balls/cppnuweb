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
Apparently there is some glue code needed so that Bison and Flex can talk to each other when using C++ for both. It seems it is easier if at least Flex is C, but I want to have only C++ code here. The code between \%\{ and \%\} is included at the beginning of the generated file. \lstinline{"parser.h"} is a header generated by Bison via the cmake rules and will contain the token definitions for example which are generated by the \verb|%token| commands following in the bison file below.

\codebisonflex
@O ../src/nuweb.y
@{
%code requires {
    #include <iostream>
    #include "parser.h"
    #include "definitions.h"
    #include "document.h"
    using namespace nuweb;
    class helpLexer;
}
@}

\codecpp
Here we need to fix a problem. Bison wants to call a function of type ``\lstinline{int yylex(yy::parser::semantic_type* yylvalue);}'' while Flex provides a method of type ``\lstinline{int yyFlexLexer::yylex(void);}''. We create a new ``\lstinline{class helpLexer : public yyFlexLexer}'' and store the value in this class. We provide a wrapper function here for Bison which has an additional argument ``\lstinline{helpLexer* lexer}'' to pass a pointer to our class object.

@O ../src/nuweb.y
@{
%code {
    #include "helplexer.h"
    int yylex(yy::parser::semantic_type* yylvalue, helpLexer* lexer){
        return lexer->yylex(yylvalue);
    };
    void yy::parser::error(const std::string& s){
        throw std::runtime_error("Bison parser error:\n    " + s + "\n");
    };
}
@}

We need to tell Bison about this new argument of course:

\codebisonflex
@d Bison flex parameters
@{
%lex-param { helpLexer* lexer }
@}

\codecpp
We also need to pass a pointer to this \lstinline{helpLexer} object in the constructor of the ``\lstinline{class yy::parser}'' which is generated for us by Bison.

\codebisonflex
@d Bison parse parameters first
@{
%parse-param { helpLexer* lexer }
@}

So let's go ahead and write this helper class.

\indexClass{helpLexer}\codecpp
@O ../src/helplexer.h -d
@{
@<Start of @'HELPLEXER@' header@>

#ifndef REFLEX_OPTION_lexer
#include "lexer.h"
#endif
#include "parser.h"
#include "file.h"
#include <iostream>

class helpLexer : public yyFlexLexer {
private:
    yy::parser::semantic_type* yylvalue;
    std::vector<std::string> filenameStack = {};
    std::istringstream* utf8Stream;
    //int yylex(void);
    unsigned int m_fragmentReferenceDepth = 0;
    @<Implementation of additional helpLexer functions@>
public:
    helpLexer(std::istream* inputStream, std::ostream* outputStream) : yyFlexLexer(inputStream, outputStream), m_fragmentReferenceDepth(0) {
    }
    helpLexer(std::istream* inputStream) : yyFlexLexer(inputStream), m_fragmentReferenceDepth(0) {
    }
    helpLexer(std::string inputString) : yyFlexLexer(inputString), m_fragmentReferenceDepth(0) {
    }
    int yylex(yy::parser::semantic_type& yylval) override;
    int yylex(yy::parser::semantic_type* yylvalue) override{
        this->yylvalue = yylvalue;
        return yylex(*yylvalue);
    }
@<End of class and header@>
@}

