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

\section{Abstract Syntax Tree}
We define some classes for our Abstract Syntax Tree. This correspond mostly to the non terminal expressions in the Bison grammar and are used there to build up the tree.

\subsection{document}
\indexHeader{DEFINITIONS}
@O ../src/definitions.h -d
@{
@<Start of @'DEFINITIONS@' header@>

#include <vector>

namespace nuweb {
@}

@O ../src/definitions.h -d
@{
@<C++ structure definitions in namespace nuweb@>
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
            m_value(value){
            };
        int m_value;
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

@O ../src/ast.h -d
@{
@<Start of @'AST@' header@>
#include <vector>
#include "document.h"
#include "definitions.h"

namespace nuweb {

@}

@O ../src/ast.h -d
@{

@<Start of class @'fragmentNamePart@' base @'documentPart@'@>
private:
    std::string m_value;
public:
    fragmentNamePart(const filePosition& l_filePosition, const std::string& value) :
        documentPart(l_filePosition), m_value(value){
            std::cout << "fragmentNamePart\n";
        };
@<End of class@>

@<Start of class @'fragmentNamePartArgument@' base @'fragmentNamePart@'@>
private:
    int m_counter;
public:
    fragmentNamePartArgument(const filePosition& l_filePosition, const std::string& argumentName, int counter):
        fragmentNamePart(l_filePosition, argumentName), m_counter(counter){
            std::cout << "fragmentNamePartArgument\n";
        };
@<End of class, namespace and header@>

@}

