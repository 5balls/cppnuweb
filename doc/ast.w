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

\subsection{nuwebDocument}
@O ../src/ast.h -d
@{
@<Start of @'AST@' header@>
#include <vector>

@<Start of class @'nuwebElement@'@>
public:
    nuwebElement(void){
        std::cout << "Constructor nuwebElement" << std::endl;
    };
@<End of class@>

@<Start of class @'texCode@' base @'nuwebElement@'@>
private:
    std::string m_contents;
public:
    texCode(std::string l_contents) : m_contents(l_contents){
        std::cout << "Constructor texCode(" << m_contents << ")" << std::endl;
    }
@<End of class@>

@<Start of class @'nuwebDocument@'@>
private:
    std::vector<nuwebElement*> m_elements;
public:
    ~nuwebDocument(void){
        for(auto* element: m_elements)
            delete element;
        m_elements.clear();
    }
    void addElement(nuwebElement* l_element){
        m_elements.push_back(l_element);
        std::cout << "nuwebDocument has now " << m_elements.size() << " elements" << std::endl;
    }

@<End of class and header@>
@}

