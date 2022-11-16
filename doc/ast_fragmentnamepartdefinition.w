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
    static std::vector<fragmentNamePartDefinition*> m_allFragmentPartDefinitions;
public:
    fragmentNamePartDefinition(filePosition* l_filePosition, bool isArgument);
    fragmentNamePartDefinition(documentPart&& l_documentPart, bool isArgument);
    fragmentNamePartDefinition(unsigned int argumentNumber);
    bool operator==(const fragmentNamePartDefinition& toCompareWith) const;
    virtual std::string texUtf8() const override;
    bool isArgument(void) const;
};
@| fragmentNamePartDefinition @}
@d \staticDefinitions{fragmentNamePartDefinition}
@{@%
std::vector<nuweb::fragmentNamePartDefinition*> nuweb::fragmentNamePartDefinition::m_allFragmentPartDefinitions = {};
@| m_allFragmentPartDefinitions @}
\subsection{Implementation}
\subsubsection{fragmentNamePartDefinition}
\indexClassMethod{fragmentDefinition}{fragmentNamePartDefinition}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
    nuweb::fragmentNamePartDefinition::fragmentNamePartDefinition(filePosition* l_filePosition, bool isArgument) : documentPart(l_filePosition), m_isArgument(isArgument), m_argumentNumber(0) {
        m_allFragmentPartDefinitions.push_back(this);
    }
@}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
    nuweb::fragmentNamePartDefinition::fragmentNamePartDefinition(documentPart&& l_documentPart, bool isArgument) : documentPart(std::move(l_documentPart)), m_isArgument(isArgument), m_argumentNumber(0) {
        m_allFragmentPartDefinitions.push_back(this);
    }
@}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
   nuweb::fragmentNamePartDefinition::fragmentNamePartDefinition(unsigned int argumentNumber) : m_argumentNumber(argumentNumber), m_isArgument(true)
    {
    }
@}

\subsubsection{operator==}
\indexClassMethod{fragmentDefinition}{operator}
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
                bool leftHandSideShortened = false;
                bool rightHandSideShortened = false;
                if(leftHandSide.find("...") == leftHandSideLength-3){
                    leftHandSide = leftHandSide.substr(0,leftHandSideLength-3);
                    leftHandSideLength -= 3;
                    leftHandSideShortened = true;
                }
                if(rightHandSide.find("...") == rightHandSideLength-3){
                    rightHandSide = rightHandSide.substr(0,rightHandSideLength-3); 
                    rightHandSideLength -= 3;
                    rightHandSideShortened = true;
                }
                return (rightHandSideShortened ? leftHandSide.substr(0,rightHandSideLength) : leftHandSide)
                    == (leftHandSideShortened ? rightHandSide.substr(0,leftHandSideLength) : rightHandSide);
            }
    }
@}
\subsubsection{texUtf8}
\indexClassMethod{fragmentDefinition}{texUtf8}
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
\indexClassMethod{fragmentDefinition}{isArgument}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
    bool nuweb::fragmentNamePartDefinition::isArgument(void) const{
        return m_isArgument;
    }
@| isArgument @}
