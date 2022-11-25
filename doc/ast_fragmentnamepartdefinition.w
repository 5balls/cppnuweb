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
    int m_argumentNumber = 0;
    documentPart* m_parent = nullptr;
    unsigned int m_namePartNumber = 0;
    static std::vector<fragmentNamePartDefinition*> m_allFragmentPartDefinitions;
    fragmentNamePartDefinition* m_longForm = nullptr;
protected:
    virtual bool isEqualWith(const fragmentNamePartDefinition& toCompareWith) const;
public:
    fragmentNamePartDefinition(filePosition* l_filePosition);
    fragmentNamePartDefinition(documentPart&& l_documentPart);
    fragmentNamePartDefinition(unsigned int argumentNumber);
    bool operator==(const fragmentNamePartDefinition& toCompareWith) const;
    bool operator!=(const fragmentNamePartDefinition& toCompareWith) const;
    virtual std::string texUtf8() const override;
    virtual std::string utf8() const override;
    virtual void resolveReferences2(void) override;
    bool isArgument(void) const;
    void setParent(documentPart*);
    void setNamePartNumber(unsigned int number);
    bool isShortened(void) const;
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
    nuweb::fragmentNamePartDefinition::fragmentNamePartDefinition(filePosition* l_filePosition) : documentPart(l_filePosition), m_isArgument(isArgument), m_argumentNumber(0) {
        m_allFragmentPartDefinitions.push_back(this);
    }
@}
\indexClassMethod{fragmentNamePartDefinition}{fragmentNamePartDefinition}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
    nuweb::fragmentNamePartDefinition::fragmentNamePartDefinition(documentPart&& l_documentPart) : documentPart(std::move(l_documentPart)), m_isArgument(isArgument), m_argumentNumber(0) {
        m_allFragmentPartDefinitions.push_back(this);
    }
@}
\indexClassMethod{fragmentNamePartDefinition}{fragmentNamePartDefinition}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
   nuweb::fragmentNamePartDefinition::fragmentNamePartDefinition(unsigned int argumentNumber) : m_argumentNumber(argumentNumber), m_isArgument(true)
    {
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
\indexClassMethod{fragmentNamePartDefinition}{operator}
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
\subsubsection{texUtf8}
\indexClassMethod{fragmentNamePartDefinition}{texUtf8}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
    std::string nuweb::fragmentNamePartDefinition::texUtf8() const{
        std::string expandedFragmentNamePart;
        // TODO move to fragmentNamePartArgument
       if(m_isArgument)
            if(m_argumentNumber>0){
                if(m_argumentNumber < 10)
                    m_texFilePositionColumnCorrection = -1;
                else if(m_argumentNumber < 100)
                    m_texFilePositionColumnCorrection = -2;
                else
                    throw std::runtime_error("More than 99 arguments not supported!");
                return "{\\tt @@}";
            }
            else
                return "\\hbox{\\slshape\\sffamily " + expandedFragmentNamePart + "\\/}";
        else
            return expandedFragmentNamePart;
    }
@| texUtf8 @}
\subsubsection{utf8}
\indexClassMethod{fragmentNamePartDefinition}{utf8}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
    std::string nuweb::fragmentNamePartDefinition::utf8() const{
        if(m_isArgument && m_argumentNumber>0)
            return "";
        else
            return documentPart::utf8();
    }
@| utf8 @}
\subsubsection{isArgument}
\indexClassMethod{fragmentNamePartDefinition}{isArgument}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
    bool nuweb::fragmentNamePartDefinition::isArgument(void) const{
        return m_isArgument;
    }
@| isArgument @}
\subsubsection{resolveReferences}
\indexClassMethod{fragmentNamePartDefinition}{resolveReferences2}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
    void nuweb::fragmentNamePartDefinition::resolveReferences2(void){
        if(m_isShortened){
            if(m_parent)
            {
                fragmentDefinition* correspondingFragmentDefinition = dynamic_cast<fragmentDefinition*>(m_parent);
                if(!correspondingFragmentDefinition){
                    fragmentReference* parentReference = dynamic_cast<fragmentReference*>(m_parent);
                    if(!parentReference)
                        throw std::runtime_error("Could not resolve shortened fragment argument!");
                    correspondingFragmentDefinition = parentReference->getFragmentDefinition();
                }
                m_longForm = correspondingFragmentDefinition->findLongFormNamePart(m_namePartNumber);

            }
            else
                throw std::runtime_error("Internal error, fragmentNamePartDefinition::m_parent not set!");
        }
    }
@| resolveReferences2 @}
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
\subsubsection{isShortened}
\indexClassMethod{fragmentNamePartDefinition}{isShortened}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
    bool nuweb::fragmentNamePartDefinition::isShortened(void) const{
        return m_isShortened;
    }
@| isShortened @}
