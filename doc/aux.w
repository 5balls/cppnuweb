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

\chapter{AUX file}
The aux file is created by \LaTeX. We need to read it to get the correct Id's for the scraps in our fragments. This scrap Id's are stored in a static variablei \codecpp\lstinline{m_scrapIds}\footnote{@d \staticDefinitions{auxFile}
@{@%
    std::map<unsigned int, std::string> nuweb::auxFile::m_scrapIds = {};
    std::map<unsigned int, unsigned int> nuweb::auxFile::m_scrapPages = {};
    std::map<unsigned int, char> nuweb::auxFile::m_scrapLetters = {};
@}
} of the class and can therefore be accessed by all members classes of the abstract syntax tree later. Currently we do everything in the constructor (that may be refactored later if we need to reread the aux file during the program run) and have once access function \codecpp\lstinline{scrapId}.

\indexClass{auxFile}
@D \classDeclaration{auxFile}
@{
class auxFile : public file {
private:
    static std::map<unsigned int, std::string> m_scrapIds;
    static std::map<unsigned int, unsigned int> m_scrapPages;
    static std::map<unsigned int, char> m_scrapLetters;
public:
    auxFile(std::string filename);
    static std::string scrapId(unsigned int scrapNumber);
    static unsigned int scrapPage(unsigned int scrapNumber);
    static char scrapLetter(unsigned int scrapNumber);
};
@| auxFile @}

The implementation of the constructor is very much straight forward structured programming.

@d \classImplementation{auxFile}
@{@%
nuweb::auxFile::auxFile(std::string filename) : nuweb::file(filename) {
    @<\functionPartImplementation{auxFile} Declare some helper variables@>
    for(unsigned int lineNumber = 0; lineNumber < numberOfLines(); lineNumber++)
    {
        @<\functionPartImplementation{auxFile} Find scrap definition@>
        @<\functionPartImplementation{auxFile} Read scrap number@>
        @<\functionPartImplementation{auxFile} Skip some text until current bracket is closed and a new one is opened@>
        @<\functionPartImplementation{auxFile} Read page number@>
        @<\functionPartImplementation{auxFile} Construct scrap Id from pagenumber and letter (if multiple scraps are on the same page)@>
    }
}
@| auxFile @}

@d \functionPartImplementation{auxFile} Declare some helper variables
@{@%
    const std::string numberCharacters = "0123456789";
    const std::string startString = "\\newlabel{scrap";
    const size_t startStringSize = startString.size();
    const std::string middleString = "}{{";
    const size_t middleStringSize = middleString.size();
@}

@d \functionPartImplementation{auxFile} Find scrap definition
@{@%
    std::string line = utf8(lineNumber);
    size_t scrapNumberStartPosition = line.find(startString);
    if(scrapNumberStartPosition == std::string::npos) continue;
@}

@d \functionPartImplementation{auxFile} Read scrap number
@{@%
    scrapNumberStartPosition += startStringSize;
    size_t scrapNumberEndPosition = line.find_first_not_of(numberCharacters, scrapNumberStartPosition);
    if(scrapNumberEndPosition == std::string::npos) continue;
    unsigned int scrapNumber = std::stoi(line.substr(scrapNumberStartPosition, scrapNumberEndPosition-scrapNumberStartPosition));
    if(line.find(middleString, scrapNumberEndPosition) != scrapNumberEndPosition) continue;
@}

@d \functionPartImplementation{auxFile} Skip some text until current bracket is closed and a new one is opened
@{@%
    size_t bracketDepth = 1;
    size_t bracketPosition = scrapNumberEndPosition + middleStringSize;
    for(; bracketPosition < line.size() && bracketDepth > 0; bracketPosition++)
        if(line.at(bracketPosition) == '{')
            bracketDepth++;
        else if (line.at(bracketPosition) == '}')
            bracketDepth--;
    if(bracketPosition == line.size()) continue;
    if(line.find("{",bracketPosition) != bracketPosition) continue;
@}

@d \functionPartImplementation{auxFile} Read page number
@{@%
    size_t pageNumberStartPosition = bracketPosition + 1;
    size_t pageNumberEndPosition = line.find_first_not_of(numberCharacters, pageNumberStartPosition);
    if(pageNumberEndPosition == std::string::npos) continue;
    unsigned int pageNumber = std::stoi(line.substr(pageNumberStartPosition, pageNumberEndPosition - pageNumberStartPosition));
@}

@d \functionPartImplementation{auxFile} Construct scrap Id from pagenumber and letter (if multiple scraps are on the same page)
@{@%
    m_scrapPages[scrapNumber] = pageNumber;
    if((m_scrapPages.find(scrapNumber-1) != m_scrapPages.end()) && m_scrapPages[scrapNumber-1] == pageNumber){
        if(m_scrapLetters[scrapNumber-1]=='\0'){
            m_scrapLetters[scrapNumber-1] = 'a';
            m_scrapIds[scrapNumber-1] = std::to_string(m_scrapPages[scrapNumber]) + 'a'; 
        }
        else if(m_scrapLetters[scrapNumber-1]=='z')
            throw std::runtime_error("Ran out of scrap letters for page " + std::to_string(m_scrapPages[scrapNumber]) + "!");
        m_scrapLetters[scrapNumber] = m_scrapLetters[scrapNumber-1] + 1;
    }
    else{
        m_scrapLetters[scrapNumber] = '\0';
    }
    if(m_scrapLetters[scrapNumber] == '\0')
        m_scrapIds[scrapNumber] = std::to_string(m_scrapPages[scrapNumber]);
    else
        m_scrapIds[scrapNumber] = std::to_string(m_scrapPages[scrapNumber]) + m_scrapLetters[scrapNumber];
@}

@d \classImplementation{auxFile}
@{@%
    std::string nuweb::auxFile::scrapId(unsigned int scrapNumber){
        if(m_scrapIds.find(scrapNumber) != m_scrapIds.end())
            return m_scrapIds[scrapNumber];
        else
            return "?";
    }
@| scrapId @}

@d \classImplementation{auxFile}
@{@%
    unsigned int nuweb::auxFile::scrapPage(unsigned int scrapNumber){
        if(m_scrapPages.find(scrapNumber) != m_scrapPages.end())
            return m_scrapPages[scrapNumber];
        else
            return 0;
    }
@| scrapPages @}

@d \classImplementation{auxFile}
@{@%
    char nuweb::auxFile::scrapLetter(unsigned int scrapNumber){
        if(m_scrapLetters.find(scrapNumber) != m_scrapLetters.end())
            return m_scrapLetters[scrapNumber];
        else
            return '\0';
    }
@| scrapPages @}



\indexClass{auxFile}
@o ../src/auxfile.h
@{@%
@<Start of @'AUXFILE@' header@>
#include "file.h"
namespace nuweb {
@<\classDeclaration{auxFile}@>
}
@<End of header@>
@}

@o ../src/auxfile.cpp -d
@{@%
#include "auxfile.h"
@<\staticDefinitions{auxFile}@>
@<\classImplementation{auxFile}@>
@}

@d C++ files without main in path @'path@'
@{@%
@1auxfile.cpp
@}
