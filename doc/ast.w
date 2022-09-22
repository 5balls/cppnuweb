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
@O ../src/ast.h -d
@{
@<Start of @'AST@' header@>
#include <vector>

namespace nuweb {

struct filePosition {
    filePosition(std::string filename,
            unsigned int line, unsigned int column,
            unsigned int line_end, unsigned int column_end):
        m_filename(filename),
        m_line(line), m_column(column),
        m_line_end(line_end), m_column_end(column_end){};
    std::string m_filename;
    unsigned int m_line;
    unsigned int m_column;
    unsigned int m_line_end;
    unsigned int m_column_end;
};

struct filePositionWithInt : public filePosition {
    int m_value;
};

struct filePositionWithString : public filePosition {
    filePositionWithString(const filePosition& l_filePosition,
            std::string value):
        filePosition(l_filePosition),
        m_value(value){};
    filePositionWithString(std::string filename, 
            unsigned int line, unsigned int column,
            unsigned int line_end, unsigned int column_end,
            std::string value):
        filePosition(filename,line,column,line_end,column_end),
        m_value(value){
        };
    std::string m_value;
};
@}

@O ../src/ast.h -d
@{
@<Start of class @'documentPart@'@>
private:
    filePosition m_filePosition;
public:
    documentPart(const filePosition& l_filePosition) : m_filePosition(l_filePosition){
        std::cout << "documentPart[" << m_filePosition.m_filename << ":" << m_filePosition.m_line << "," << m_filePosition.m_column << "|" << m_filePosition.m_line_end << "," << m_filePosition.m_column_end << ").";
    };
@<End of class@>

@<Start of class @'texCode@' base @'documentPart@'@>
private:
    std::string m_contents;
public:
    texCode(const filePositionWithString& l_filePosition) : documentPart(filePosition(l_filePosition.m_filename, l_filePosition.m_line, l_filePosition.m_column, l_filePosition.m_line_end, l_filePosition.m_column_end)), m_contents(l_filePosition.m_value){
        std::cout << "texCode\n";
        //std::cout << "texCode(" << m_contents << ")";
    }
@<End of class@>

@<Start of class @'includeFile@' base @'documentPart@'@>
private:
    std::string m_filename;
public:
    includeFile(const filePositionWithString& l_filePosition) : documentPart(filePosition(l_filePosition.m_filename, l_filePosition.m_line, l_filePosition.m_column, l_filePosition.m_line_end, l_filePosition.m_column_end)), m_filename(l_filePosition.m_value){
        //std::cout << "includeFile";
        std::cout << "includeFile(" << m_filename << ")\n";
    }
@<End of class@>

@<Start of class @'outputFile@' base @'documentPart@'@>
private:
    std::string m_filename;
public:
    outputFile(const filePosition& l_filePosition, std::string filename) : documentPart(l_filePosition), m_filename(filename){
        //std::cout << "outputFile";
        std::cout << "outputFile(" << m_filename << ")\n";
    }
@<End of class@>

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
@<End of class@>

@<Start of class @'document@'@>
private:
    std::vector<documentPart*> m_documentParts;
public:
    ~document(void){
        for(auto* documentPart: m_documentParts)
            delete documentPart;
        m_documentParts.clear();
    }
    void addElement(documentPart* l_documentPart){
        m_documentParts.push_back(l_documentPart);
        std::cout << m_documentParts.size();
        //std::cout << "document has now " << m_documentParts.size() << " documentParts" << std::endl;
    }
@<End of class, namespace and header@>
@}

