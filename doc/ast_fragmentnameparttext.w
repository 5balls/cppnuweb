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

\section{Class fragmentNamePartText}
\subsection{Interface}
\indexClass{fragmentNamePartText}
@d \classDeclaration{fragmentNamePartText}
@{@%
class fragmentNamePartText : public fragmentNamePartDefinition, public documentPart {
private:
    bool m_isShortened = false;
    fragmentNamePartText* m_longForm = nullptr;
protected:
    virtual bool isEqualWith(const fragmentNamePartDefinition& toCompareWith) const override;
public:
    fragmentNamePartText(filePosition* l_filePosition);
    fragmentNamePartText(documentPart&& l_documentPart);
    virtual std::string texUtf8(void) const override;
    virtual std::string fileUtf8(filePosition& l_filePosition) const override;
    virtual void resolveReferences2(void) override;
    bool isShortened(void);
};
@| fragmentNamePartText @}
\subsubsection{fragmentNamePartText}
\indexClassMethod{fragmentNamePartText}{fragmentNamePartText}
@d \classImplementation{fragmentNamePartText}
@{@%
     nuweb::fragmentNamePartText::fragmentNamePartText(filePosition* l_filePosition) : fragmentNamePartDefinition(), documentPart(l_filePosition){
         filePosition ll_filePosition("",1,documentPart::m_fileIndentation+1,1,1);
         m_isShortened = (utf8(ll_filePosition).find("...") == utf8(ll_filePosition).length() - 3);
    }
@| fragmentNamePartText @}
\subsubsection{fragmentNamePartText}
\indexClassMethod{fragmentNamePartText}{fragmentNamePartText}
@d \classImplementation{fragmentNamePartText}
@{@%
     nuweb::fragmentNamePartText::fragmentNamePartText(documentPart&& l_documentPart) : fragmentNamePartDefinition(), documentPart(std::move(l_documentPart)){
         filePosition ll_filePosition("",1,documentPart::m_fileIndentation+1,1,1);
         m_isShortened = (utf8(ll_filePosition).find("...") == utf8(ll_filePosition).length() - 3);
    }
@| fragmentNamePartText @}
\subsubsection{isEqualWith}
\indexClassMethod{fragmentNamePartText}{isEqualWith}
@d \classImplementation{fragmentNamePartText}
@{@%
    bool nuweb::fragmentNamePartText::isEqualWith(const fragmentNamePartDefinition& toCompareWith) const{
       if(typeid(*this)!=typeid(toCompareWith))
           return false; 
       const fragmentNamePartText& l_toCompareWith = static_cast<const fragmentNamePartText&>(toCompareWith);
       filePosition ll_filePosition("",1,documentPart::m_fileIndentation+1,1,1);
       std::string leftHandSide = utf8(ll_filePosition);
       std::string rightHandSide = l_toCompareWith.utf8(ll_filePosition);
       size_t leftHandSideLength = leftHandSide.length();
       size_t rightHandSideLength = rightHandSide.length();
       if(m_isShortened){
           leftHandSide = leftHandSide.substr(0,leftHandSideLength-3);
           leftHandSideLength -= 3;
       }
       if(l_toCompareWith.m_isShortened){
           rightHandSide = rightHandSide.substr(0,rightHandSideLength-3); 
           rightHandSideLength -= 3;
       }
       if ((l_toCompareWith.m_isShortened ? leftHandSide.substr(0,rightHandSideLength) : leftHandSide)
           != (m_isShortened ? rightHandSide.substr(0,leftHandSideLength) : rightHandSide))
           return false;
       return fragmentNamePartDefinition::isEqualWith(toCompareWith);
    }
@| isEqualWith @}
\subsubsection{texUtf8}
\indexClassMethod{fragmentNamePartText}{texUtf8}
@d \classImplementation{fragmentNamePartText}
@{@%
    std::string nuweb::fragmentNamePartText::texUtf8(void) const{
        std::string expandedFragmentNamePart;
        filePosition ll_filePosition("",1,documentPart::m_fileIndentation+1,1,1);
        if(m_isShortened)
            if(!m_longForm)
                std::cout << "Could not find long form for argument \"" + utf8(ll_filePosition) + "\"!\n";
            else
                expandedFragmentNamePart = m_longForm->utf8(ll_filePosition);
        else
            expandedFragmentNamePart = utf8(ll_filePosition);
        return expandedFragmentNamePart;
    }
@| texUtf8 @}
\subsubsection{fileUtf8}
\indexClassMethod{fragmentNamePartText}{fileUtf8}
@d \classImplementation{fragmentNamePartText}
@{@%
    std::string nuweb::fragmentNamePartText::fileUtf8(filePosition& l_filePosition) const{
        if(m_isShortened && m_longForm)
            return m_longForm->fileUtf8(l_filePosition);
        else
            return documentPart::fileUtf8(l_filePosition);
    }
@| fileUtf8 @}
\subsubsection{resolveReferences2}
\indexClassMethod{fragmentNamePartText}{resolveReferences2}
@d \classImplementation{fragmentNamePartText}
@{@%
    void nuweb::fragmentNamePartText::resolveReferences2(void){
        if(m_isShortened){
            if(!m_parent)
                throw std::runtime_error("Internal error, fragmentNamePartDefinition::m_parent not set!");
            fragmentDefinition* correspondingFragmentDefinition = dynamic_cast<fragmentDefinition*>(m_parent);
            if(!correspondingFragmentDefinition){
                fragmentReference* parentReference = dynamic_cast<fragmentReference*>(m_parent);
                if(!parentReference)
                    throw std::runtime_error("Could not resolve shortened fragment argument!");
                correspondingFragmentDefinition = parentReference->getFragmentDefinition();
            }
            m_longForm = correspondingFragmentDefinition->findLongFormNamePart(m_namePartNumber);
        }
    }
@| resolveReferences2 @}
\subsubsection{isShortened}
\indexClassMethod{fragmentNamePartText}{isShortened}
@d \classImplementation{fragmentNamePartText}
@{@%
    bool nuweb::fragmentNamePartText::isShortened(void){
        return m_isShortened;
    }
@| isShortened @}
