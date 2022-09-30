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

\chapter{Abstract Syntax Tree Classes}
We define some classes for our Abstract Syntax Tree. This correspond mostly to the non terminal expressions in the Bison grammar and are used there to build up the tree.

\section{General definitions}
\indexHeader{DEFINITIONS}
@O ../src/definitions.h -d
@{
@<Start of @'DEFINITIONS@' header@>

#include <vector>
#include <iostream>

namespace nuweb {
@}

@O ../src/definitions.h -d
@{
@<C++ structure definitions in namespace nuweb@>
@<C++ enum class definitions in namespace nuweb@>
@}

\indexStructure{filePositionWithInt}
@O ../src/definitions.h -d
@{
    struct filePositionWithInt : public filePosition {
        filePositionWithInt(const std::string& filename, 
                unsigned int line, unsigned int column,
                unsigned int line_end, unsigned int column_end,
                int value):
            filePosition(filename,line,column,line_end,column_end),
            mn_value(value){
            };
        int mn_value;
    };
@}

\indexStructure{filePositionWithString}
@O ../src/definitions.h -d
@{
    struct filePositionWithString : public filePosition {
        filePositionWithString(const filePosition& l_filePosition,
                std::string value):
            filePosition(l_filePosition),
            m_value(value){};
        filePositionWithString(const std::string& filename, 
                unsigned int line, unsigned int column,
                unsigned int line_end, unsigned int column_end,
                const std::string& value):
            filePosition(filename,line,column,line_end,column_end),
            m_value(value){
                //std::cout << "filePositionWithString::filePositionWithString::value" << value << "";
                //std::cout << "filePositionWithString::filePositionWithString::m_value" << value << "";
            };
        std::string m_value;
    };
}
@<End of header@>
@}

\section{Class document}
\subsection{Interface}
\indexHeader{DOCUMENT}
@O ../src/document.h -d
@{
@<Start of @'DOCUMENT@' header@>

#include "documentPart.h"

@<Start of class @'document@' in namespace @'nuweb@'@>
@<\classDeclaration{document}@>
@<End of class, namespace and header@>
@}

\subsection{Implementation}
See @{@<\classDeclaration{document}@>@}.

\section{Class documentPart and derived classes}
\subsection{Interface}
\indexHeader{DOCUMENT\_PART}@O ../src/documentPart.h -d
@{
@<Start of @'DOCUMENT_PART@' header@>

#include <vector>
#include "definitions.h"
#include "file.h"

namespace nuweb {
@<\classDeclaration{documentPart}@>
@<End of class@>

@<Start of class @'emptyDocumentPart@' public @'documentPart@'@>
@<\classDeclaration{emptyDocumentPart}@>
@<End of class@>

@<Start of class @'outputFile@' public @'documentPart@'@>
@<\classDeclaration{outputFile}@>
@<End of class@>

@<\classDeclaration{escapeCharacterDocumentPart}@>
@<\classDeclaration{scrap}@>
@<\classDeclaration{scrapVerbatim}@>

@<\classDeclaration{fragmentDefinition}@>

@<Start of class @'fragmentNamePartDefinition@' public @'documentPart@'@>
@<\classDeclaration{fragmentNamePartDefinition}@>
@<End of class, namespace and header@>
@}

\subsection{Implementation}
@d C++ files without main in path @'path@'
@{@1documentPart.cpp
@}

@o ../src/documentPart.cpp -d
@{
#include "documentPart.h"

@<\staticDefinitions{escapeCharacterDocumentPart}@>
@<\staticDefinitions{fragmentNamePartDefinition}@>

@<\classImplementation{documentPart}@>
@}

\subsubsection{utf8}
\indexClassMethod{documentPart}{utf8}
@d \classImplementation{documentPart}
@{@%
std::string nuweb::documentPart::utf8(void) const{
    if(empty()){
        // Line numbers in lex start by one, internally we start at 0, so we
        // have to substract one here:
        file* l_file = file::byName(m_filePosition->m_filename);
        return l_file->utf8({{m_filePosition->m_line-1,m_filePosition->m_column},
                {m_filePosition->m_line_end-1,m_filePosition->m_column_end}});
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
@{
std::string nuweb::documentPart::texUtf8() const{
    return utf8();
};
@| texUtf8 @}

