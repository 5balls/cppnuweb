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

