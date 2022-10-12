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

\section{Class documentPart}
\subsection{Interface}
\indexHeader{DOCUMENT\_PART}@O ../src/documentPart.h -d
@{@%
@<Start of @'DOCUMENT_PART@' header@>
#include <vector>
#include <algorithm>
#include <fstream>
#include "definitions.h"
#include "file.h"
#include "auxfile.h"

namespace nuweb {
@<\classDeclaration{documentPart}@>
@<\classDeclaration{escapeCharacterDocumentPart}@>
@<\classDeclaration{scrap}@>
@<\classDeclaration{scrapVerbatim}@>
@<\classDeclaration{fragmentDefinition}@>
@<\classDeclaration{fragmentNamePartDefinition}@>
@<\classDeclaration{fragmentReference}@>
@<\classDeclaration{outputFile}@>
@<\classDeclaration{emptyDocumentPart}@>
@<\classDeclaration{fragmentArgument}@>
}
@<End of header@>
@}

\subsection{Implementation}
@d C++ files without main in path @'path@'
@{@1documentPart.cpp
@}

@o ../src/documentPart.cpp -d
@{
#include "documentPart.h"

@<\staticDefinitions{documentPart}@>
@<\staticDefinitions{escapeCharacterDocumentPart}@>
@<\staticDefinitions{fragmentDefinition}@>
@<\staticDefinitions{fragmentNamePartDefinition}@>
@<\staticDefinitions{outputFile}@>

@<\classImplementation{documentPart}@>
@<\classImplementation{fragmentDefinition}@>
@<\classImplementation{fragmentReference}@>
@<\classImplementation{fragmentNamePartDefinition}@>
@<\classImplementation{outputFile}@>
@<\classImplementation{scrapVerbatim}@>
@<\classImplementation{fragmentArgument}@>
@}
\subsubsection{utf8}
\indexClassMethod{documentPart}{utf8}
@d \classImplementation{documentPart}
@{@%
std::string nuweb::documentPart::utf8(void) const{
    if(empty()){
        // Line numbers in lex start by one, internally we start at 0, so we
        // have to substract one here:
        if(!m_filePosition) throw std::runtime_error("Internal error: documentPart without file pointer!");
        std::string filename = m_filePosition->m_filename;
        if(filename.empty())
            return "";
        else {
            file* l_file = file::byName(filename);
            //std::cout << "File access in \"" << m_filePosition->m_filename << "\": " << m_filePosition->m_line-1 << "," << m_filePosition->m_column << " " << m_filePosition->m_line_end-1 << "," << m_filePosition->m_column_end << "\n";
            return l_file->utf8({{m_filePosition->m_line-1,m_filePosition->m_column},
                    {m_filePosition->m_line_end-1,m_filePosition->m_column_end}});
        }
    }
    else{
        std::string returnString;
        for(auto documentPart: *this)
            returnString += documentPart->utf8();
        return returnString;
    }
}
@| utf8 @}
\subsubsection{texUtf8}
\indexClassMethod{documentPart}{texUtf8}
@d \classImplementation{documentPart}
@{@%
std::string nuweb::documentPart::texUtf8() const{
    if(empty()){
        return utf8();
    }
    else{
        std::string returnString;
        for(auto& documentPart: *this)
            returnString += documentPart->texUtf8();
        return returnString;
    }
};
@| texUtf8 @}
\subsubsection{fileUtf8}
\indexClassMethod{documentPart}{fileUtf8}
@d \classImplementation{documentPart}
@{@%
std::string nuweb::documentPart::fileUtf8() const{
    if(empty()){
        return utf8();
    }
    else{
        std::string returnString;
        for(auto& documentPart: *this)
            returnString += documentPart->fileUtf8();
        return returnString;
    }
}
@}

