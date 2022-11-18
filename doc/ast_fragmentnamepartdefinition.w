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
    bool m_isArgument = false;
    bool m_isShortened = false;
    documentPart* m_parent = nullptr;
    unsigned int m_namePartNumber = 0;
    static std::vector<fragmentNamePartDefinition*> m_allFragmentPartDefinitions;
public:
    fragmentNamePartDefinition(filePosition* l_filePosition, bool isArgument);
    fragmentNamePartDefinition(documentPart&& l_documentPart, bool isArgument);
    fragmentNamePartDefinition(unsigned int argumentNumber);
    bool operator==(const fragmentNamePartDefinition& toCompareWith) const;
    virtual std::string texUtf8() const override;
    virtual void resolveReferences(void) override;
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
    nuweb::fragmentNamePartDefinition::fragmentNamePartDefinition(filePosition* l_filePosition, bool isArgument) : documentPart(l_filePosition), m_isArgument(isArgument), m_argumentNumber(0) {
        if(m_isArgument)
            m_isShortened = false;
        else
            m_isShortened = (utf8().find("...") == utf8().length() - 3);
        m_allFragmentPartDefinitions.push_back(this);
    }
@}
\indexClassMethod{fragmentNamePartDefinition}{fragmentNamePartDefinition}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
    nuweb::fragmentNamePartDefinition::fragmentNamePartDefinition(documentPart&& l_documentPart, bool isArgument) : documentPart(std::move(l_documentPart)), m_isArgument(isArgument), m_argumentNumber(0) {
        if(m_isArgument)
            m_isShortened = false;
        else
            m_isShortened = (utf8().find("...") == utf8().length() - 3);
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

\subsubsection{operator==}
\indexClassMethod{fragmentNamePartDefinition}{operator}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
    bool nuweb::fragmentNamePartDefinition::operator==(const fragmentNamePartDefinition& toCompareWith) const{
        if(m_isArgument && toCompareWith.m_isArgument)
            return m_isArgument == toCompareWith.m_isArgument;
        else
            if(m_isArgument != toCompareWith.m_isArgument)
                return false;
            else
            {
                std::string leftHandSide = utf8();
                std::string rightHandSide = toCompareWith.utf8();
                size_t leftHandSideLength = leftHandSide.length();
                size_t rightHandSideLength = rightHandSide.length();
                if(m_isShortened){
                    leftHandSide = leftHandSide.substr(0,leftHandSideLength-3);
                    leftHandSideLength -= 3;
                }
                if(toCompareWith.m_isShortened){
                    rightHandSide = rightHandSide.substr(0,rightHandSideLength-3); 
                    rightHandSideLength -= 3;
                }
                return (toCompareWith.m_isShortened ? leftHandSide.substr(0,rightHandSideLength) : leftHandSide)
                    == (m_isShortened ? rightHandSide.substr(0,leftHandSideLength) : rightHandSide);
            }
    }
@}
\subsubsection{texUtf8}
\indexClassMethod{fragmentNamePartDefinition}{texUtf8}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
    std::string nuweb::fragmentNamePartDefinition::texUtf8() const{
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
                return "\\hbox{\\slshape\\sffamily " + utf8() + "\\/}";
        else
            return utf8();
    }
@| texUtf8 @}

\subsubsection{isArgument}
\indexClassMethod{fragmentNamePartDefinition}{isArgument}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
    bool nuweb::fragmentNamePartDefinition::isArgument(void) const{
        return m_isArgument;
    }
@| isArgument @}
\subsubsection{resolveReferences}
\indexClassMethod{fragmentNamePartDefinition}{resolveReferences}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
    void nuweb::fragmentNamePartDefinition::resolveReferences(void){
        if(m_isShortened){
            // TODO Find long form alternative
        }
    }
@| resolveReferences @}
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
