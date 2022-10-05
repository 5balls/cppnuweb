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
