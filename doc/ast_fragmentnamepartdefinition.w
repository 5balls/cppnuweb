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

\section{Class fragmentNamePartDefinition}
\subsection{Interface}
@d \classDeclaration{fragmentNamePartDefinition}
@{@%
class fragmentNamePartDefinition : public documentPart {
private:
    static std::vector<fragmentNamePartDefinition*> m_allFragmentPartDefinitions;
protected:
    documentPart* m_parent = nullptr;
    unsigned int m_namePartNumber = 0;
    virtual bool isEqualWith(const fragmentNamePartDefinition& toCompareWith) const;
public:
    fragmentNamePartDefinition(filePosition* l_filePosition);
    fragmentNamePartDefinition(documentPart&& l_documentPart);
    fragmentNamePartDefinition(unsigned int argumentNumber);
    bool operator==(const fragmentNamePartDefinition& toCompareWith) const;
    bool operator!=(const fragmentNamePartDefinition& toCompareWith) const;
    void setParent(documentPart*);
    void setNamePartNumber(unsigned int number);
};
@| fragmentNamePartDefinition @}
@d \staticDefinitions{fragmentNamePartDefinition}
@{@%
std::vector<nuweb::fragmentNamePartDefinition*> nuweb::fragmentNamePartDefinition::m_allFragmentPartDefinitions = {};
@| m_allFragmentPartDefinitions @}
\subsection{Implementation}
\subsubsection{fragmentNamePartDefinition}
\indexClassMethod{fragmentNamePartDefinition}{fragmentNamePartDefinition}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
    nuweb::fragmentNamePartDefinition::fragmentNamePartDefinition(filePosition* l_filePosition) : documentPart(l_filePosition) {
        m_allFragmentPartDefinitions.push_back(this);
    }
@}
\indexClassMethod{fragmentNamePartDefinition}{fragmentNamePartDefinition}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
    nuweb::fragmentNamePartDefinition::fragmentNamePartDefinition(documentPart&& l_documentPart) : documentPart(std::move(l_documentPart)) {
        m_allFragmentPartDefinitions.push_back(this);
    }
@}
\subsubsection{isEqualWith}
\indexClassMethod{fragmentNamePartDefinition}{isEqualWith}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
    bool nuweb::fragmentNamePartDefinition::isEqualWith(const fragmentNamePartDefinition& toCompareWith) const{
        // Possible TODO: Comparison part for fragmentNamePartDefinition would go into the else
        if(typeid(*this) != typeid(toCompareWith))
            return false;
        else
            return true;
    }
@| isEqualWith @}
\subsubsection{operator==}
\indexClassMethod{fragmentNamePartDefinition}{operator==}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
    bool nuweb::fragmentNamePartDefinition::operator==(const fragmentNamePartDefinition& toCompareWith) const{
        return this->isEqualWith(toCompareWith);
    }
@}
\subsubsection{operator!=}
\indexClassMethod{fragmentNamePartDefinition}{operator!=}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
    bool nuweb::fragmentNamePartDefinition::operator!=(const fragmentNamePartDefinition& toCompareWith) const{
        return !(*this == toCompareWith);
    }
@| operator!= @}
\subsubsection{setParent}
\indexClassMethod{fragmentNamePartDefinition}{setParent}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
    void nuweb::fragmentNamePartDefinition::setParent(documentPart* parent){
        m_parent = parent;
    }
@| setParent @}
\subsubsection{setNamePartNumber}
\indexClassMethod{fragmentNamePartDefinition}{setNamePartNumber}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
    void nuweb::fragmentNamePartDefinition::setNamePartNumber(unsigned int number){
        m_namePartNumber = number;
    }
@| setNamePartNumber @}
