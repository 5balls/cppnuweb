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

\section{Main}

\codecpp
@O ../src/main.h -d
@{
@<Start of @'MAIN@' header@>
#include <iostream>
#include "file.h"
#include "helplexer.h"

#define STRINGIFY(x) #x
#define TOSTRING(x) STRINGIFY(x)

@<End of header@>
@}

\codecpp
@O ../src/main.cpp -d
@{
#include "main.h"

int main(int argc, char *argv[])
{
    std::cout << "C++ nuweb (version: " << TOSTRING(CPPNUWEB_VERSION) << ", git: " << TOSTRING(GIT_VERSION) << ")" << std::endl;
    if(argc<2){
        std::cout << "Usage: nuweb <flags> <filename>" << std::endl;
        return EXIT_FAILURE;
    }
    try{
        std::string entryString = "@@i " + std::string(argv[argc-1]);
        document* nuwebAstEntry = nullptr;
#ifdef REFLEX
        std::stringstream entryStream(entryString);
        helpLexer* lexer = new helpLexer(&entryStream);
#else
        helpLexer* lexer = new helpLexer(std::stringstream(entryString), std::cout); 
#endif
        yy::parser* parser = new yy::parser(lexer,&nuwebAstEntry);
        int parserReturnValue = parser->parse();
        delete parser;
        delete lexer;

        std::cout << "Document contains " << std::to_string(nuwebAstEntry->size()) << " parts\n";
        std::cout << "\"" + nuwebAstEntry->texUtf8() + "\"\n";
        return EXIT_SUCCESS;
    }    
    catch(std::runtime_error& e){
        std::cout << "Parsing file \"" + std::string(argv[argc-1]) + "\" failed with error:\n  " << e.what() << std::endl;
        return EXIT_FAILURE;
    }
}
@}
