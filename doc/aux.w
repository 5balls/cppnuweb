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
The aux file is created by \LaTeX.

@D \classDeclaration{auxFile}
@{
class auxFile : public file {
private:
    static std::map<unsigned int, unsigned int> m_scrapPages;
public:
    auxFile(std::string filename);
    static unsigned int scrapPage(unsigned int scrapNumber);
};
@}

@d \staticDefinitions{auxFile}
@{@%
std::map<unsigned int, unsigned int> nuweb::auxFile::m_scrapPages = {};
@}

@d \classImplementation{auxFile}
@{@%
nuweb::auxFile::auxFile(std::string filename) : nuweb::file(filename) {
    const std::string numberCharacters = "0123456789";
    const std::string startString = "\\newlabel{scrap";
    const size_t startStringSize = startString.size();
    const std::string middleString = "}{{";
    const size_t middleStringSize = middleString.size();
    for(unsigned int lineNumber = 0; lineNumber < numberOfLines(); lineNumber++)
    {
        std::string line = utf8(lineNumber);
        size_t scrapNumberStartPosition = line.find(startString);
        if(scrapNumberStartPosition == std::string::npos) continue;
        scrapNumberStartPosition += startStringSize;
        size_t scrapNumberEndPosition = line.find_first_not_of(numberCharacters, scrapNumberStartPosition);
        if(scrapNumberEndPosition == std::string::npos) continue;
        unsigned int scrapNumber = std::stoi(line.substr(scrapNumberStartPosition, scrapNumberEndPosition-scrapNumberStartPosition));
        if(line.find(middleString, scrapNumberEndPosition) != scrapNumberEndPosition) continue;
        size_t bracketDepth = 1;
        size_t bracketPosition = scrapNumberEndPosition + middleStringSize;
        for(; bracketPosition < line.size() && bracketDepth > 0; bracketPosition++)
            if(line.at(bracketPosition) == '{')
                bracketDepth++;
            else if (line.at(bracketPosition) == '}')
                bracketDepth--;
        if(bracketPosition == line.size()) continue;
        if(line.find("{",bracketPosition) != bracketPosition) continue;
        size_t pageNumberStartPosition = bracketPosition + 1;
        size_t pageNumberEndPosition = line.find_first_not_of(numberCharacters, pageNumberStartPosition);
        if(pageNumberEndPosition == std::string::npos) continue;
        unsigned int pageNumber = std::stoi(line.substr(pageNumberStartPosition, pageNumberEndPosition - pageNumberStartPosition));
        m_scrapPages[scrapNumber] = pageNumber;
    }
}
@}

@d \classImplementation{auxFile}
@{@%
    unsigned int nuweb::auxFile::scrapPage(unsigned int scrapNumber){
        if(m_scrapPages.find(scrapNumber) != m_scrapPages.end())
            return m_scrapPages[scrapNumber];
        else
            return 0;
    }
@}

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

@o ../src/auxfile.cpp
@{@%
#include "auxfile.h"
@<\staticDefinitions{auxFile}@>
@<\classImplementation{auxFile}@>
@}

@d C++ files without main in path @'path@'
@{@%
@1auxfile.cpp
@}
