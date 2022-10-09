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
#include <fstream>
#include "popl-1.3.0/include/popl.hpp"
#include "helplexer.h"
#include "auxfile.h"

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
    popl::OptionParser l_optionParser("Usage: nuweb [flags] <filename>");
    auto showHelp = l_optionParser.add<popl::Switch>("","help","Show this help.");
    auto suppressGenerationOfTexFile = l_optionParser.add<popl::Switch>("t","no-tex","Don't write the .tex file.");
    auto suppressGenerationOfOutputFiles = l_optionParser.add<popl::Switch>("o","no-output","Don't write output files.");
    /*auto forceOverwrite = l_optionParser.add<popl::Switch>("c","","Force overwrite of files.");
    auto verboseMessages = l_optionParser.add<popl::Switch>("v","verbose","Show verbose processing messages.");
    auto sequentialScrapNumbering = l_optionParser.add<popl::Switch>("n","","Number scraps sequentially.");
    auto listDanglingIdentifierReferences = l_optionParser.add<popl::Switch>("d","","Show unresolved identifier references in the indexes.");
    auto prependPath = l_optionParser.add<popl::Value<std::string> >("p","path","Prepend path to the filenames for all the output files.");*/
    auto listingsPackage = l_optionParser.add<popl::Switch>("l","listings","Use the listings package for formatting scraps.");
    /*auto versionOption = l_optionParser.add<popl::Value<std::string> >("V","","Provide string as the replacement for the @@v operation.");
    auto suppressScrapList = l_optionParser.add<popl::Switch>("s","","Don't print list of scraps making up a file at end of each scrap.");
    auto includeCrossReference = l_optionParser.add<popl::Switch>("x","","Include cross-reference numbers in the comments of scraps.");
    auto hyperrefOptions = l_optionParser.add<popl::Value<std::string> >("h","","Provide options for the hyperref package.");*/
    auto hyperLinks = l_optionParser.add<popl::Switch>("r","hyperlinks","Turn on hyperlinks. You must include the —usepackage— options in the text");
    l_optionParser.parse(argc, argv);
    if(l_optionParser.non_option_args().size() != 1){
        std::cout << l_optionParser;
        return EXIT_FAILURE;
    }
    if(showHelp->is_set()){
        std::cout << l_optionParser;
        return EXIT_SUCCESS;
    }
    std::string filename = l_optionParser.non_option_args().front();
    document* nuwebAstEntry = nullptr;
    // Parse nuweb file 
    try{
        std::stringstream entryStream("@@i " + filename);
        helpLexer* lexer = new helpLexer(&entryStream);
        yy::parser* parser = new yy::parser(lexer,&nuwebAstEntry);
        int parserReturnValue = parser->parse();
        delete parser;
        delete lexer;
    }
    catch(std::runtime_error& e){
        std::cout << "Parsing file \"" + filename + "\" failed with error:\n  " << e.what() << std::endl;
        return EXIT_FAILURE;
    }
    // Set some command line options
    nuwebAstEntry->setListingsPackageEnabled(listingsPackage->is_set());
    nuwebAstEntry->setHyperlinksEnabled(hyperLinks->is_set());
    // Parse aux file
    try{
        std::string auxFileName = filename.substr(0,filename.find_last_of('.')) + "_dbg.aux";
        nuweb::auxFile l_auxFile(auxFileName);
        nuwebAstEntry->setAuxFileParsed(true);
    }
    catch(std::runtime_error& e){
        std::cout << e.what() << "\n";
        std::cout << "You'll need to rerun nuweb after running latex\n";
    }
    if(!suppressGenerationOfTexFile->is_set()){
        try{
            std::ofstream texFile;
            std::string texFileName = filename.substr(0,filename.find_last_of('.')) + "_dbg.tex";
            texFile.open(texFileName);
            std::string texContent = nuwebAstEntry->texUtf8();
            texFile  << texContent + "\n";
            texFile.close();
        }    
        catch(std::runtime_error& e){
            std::cout << e.what() << "\n";
            std::cout << "Error when writing .tex file!\n";
            return EXIT_FAILURE;
        }
    }
    if(!suppressGenerationOfOutputFiles->is_set()){
        try{
            outputFile::writeFiles();
        }
        catch(std::runtime_error& e){
            std::cout << e.what() << "\n";
            std::cout << "Error when writing output files!\n";
            return EXIT_FAILURE;
        }
    }
    return EXIT_SUCCESS;
}
@}
