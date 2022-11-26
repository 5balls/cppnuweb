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

\section{Class fragmentReference}
\subsection{Interface}
@d \classDeclaration{fragmentReference}
@{@%
class fragmentReference : public documentPart {
private:
    fragmentDefinition* m_fragment;
    documentPart* m_referenceFragmentName;
    documentPart* m_unresolvedFragmentName;
    unsigned int m_scrapNumber;
    bool m_expandReference;
    unsigned int m_leadingSpaces = 0;
public:
    fragmentReference(documentPart* fragmentName, bool expandReference=false);
    virtual std::string utf8(filePosition& l_filePosition) const override;
    virtual std::string texUtf8(void) const override;
    virtual std::string fileUtf8(filePosition& l_filePosition) const override;
    virtual void resolveReferences(void) override;
    virtual void resolveReferences2(void) override;
    void setExpandReference(bool expandReference);
    fragmentDefinition* getFragmentDefinition(void) const;
    documentPart* getFragmentName(void) const;
    unsigned int getScrapNumber(void) const;
};
@}

\subsection{Implementation}
\subsubsection{fragmentReference}
\indexClassMethod{fragmentReference}{fragmentReference}
@d \classImplementation{fragmentReference}
@{@%
    nuweb::fragmentReference::fragmentReference(documentPart* fragmentName, bool expandReference) : m_unresolvedFragmentName(nullptr), m_referenceFragmentName(fragmentName), m_expandReference(expandReference){
        unsigned int fragmentNamePartNumber = 0;
        for(auto& fragmentNamePart: *m_referenceFragmentName){
            fragmentNamePartDefinition* fragmentArgument = dynamic_cast<fragmentNamePartDefinition*>(fragmentNamePart);
            if(fragmentArgument)
            {
                fragmentArgument->setParent(this);
                fragmentArgument->setNamePartNumber(fragmentNamePartNumber);
            }
            fragmentNamePartNumber++;
        }
        m_fragment = fragmentDefinition::fragmentFromFragmentName(fragmentName);
        if(!m_fragment)
            m_unresolvedFragmentName = fragmentName;
        else{
            //std::cout << "DEBUG " << this << " " << __LINE__ << " " << __FUNCTION__ << "\n";
            m_fragment->addReference(this);
        }
        m_scrapNumber = fragmentDefinition::totalNumberOfScraps() + 1;
    }
@}
\subsubsection{texUtf8}
\indexClassMethod{fragmentReference}{texUtf8}
@d \classImplementation{fragmentReference}
@{@%
    std::string nuweb::fragmentReference::texUtf8(void) const{
        if(!m_fragment) throw std::runtime_error("Could not resolve fragment \"" + m_unresolvedFragmentName->texUtf8() + "\" in file " + m_unresolvedFragmentName->filePositionString());
        if(m_expandReference){
            filePosition l_filePosition;
            return m_fragment->fileUtf8(l_filePosition, m_referenceFragmentName);
        }
        else {
            std::string returnString = "@@\\hbox{$\\langle\\,${\\itshape ";
            for(const auto& m_referenceFragmentNamePart: *m_referenceFragmentName){
                fragmentNamePartDefinition* referenceNamePart = dynamic_cast<fragmentNamePartDefinition*>(m_referenceFragmentNamePart);
                if(!referenceNamePart) 
                    throw std::runtime_error("Internal error, could not get fragment reference name correctly!");
                if(dynamic_cast<fragmentNamePartArgumentString*>(referenceNamePart)){
                    filePosition ll_filePosition("",1,documentPart::m_fileIndentation+1,1,1);
                    if(listingsPackageEnabled())
                        returnString += "\\lstinline@@" + referenceNamePart->utf8(ll_filePosition) + "@@";
                    else
                        returnString += "\\verb@@" + referenceNamePart->utf8(ll_filePosition) + "@@";
                }
                else
                    returnString += referenceNamePart->texUtf8();
            }
            returnString += "}\\nobreak\\ {\\footnotesize \\NWlink{nuweb";
            std::string scrapNumber = "?";
            if(documentPart::auxFileWasParsed())
                scrapNumber = auxFile::scrapId(m_fragment->scrapNumber());
            else
                std::cout << "No aux file yet, need to run Latex again!\n";
            returnString += scrapNumber + "}{" + scrapNumber + "}";
            if(m_fragment->scrapsFromFragment().size() > 1)
                returnString += ", \\ldots\\ ";
            if(listingsPackageEnabled())
                returnString += "}$\\,\\rangle$}\\lstinline@@";
            else
                returnString += "}$\\,\\rangle$}\\verb@@";
            return returnString;
        }
    }
@}
\subsubsection{utf8}
\indexClassMethod{fragmentReference}{utf8}
@d \classImplementation{fragmentReference}
@{@%
    std::string nuweb::fragmentReference::utf8(filePosition& l_filePosition) const{
        return "";
    }
@}
\subsubsection{fileUtf8}
\indexClassMethod{fragmentReference}{fileUtf8}
@d \classImplementation{fragmentReference}
@{@%
    std::string nuweb::fragmentReference::fileUtf8(filePosition& l_filePosition) const{
        if(!m_fragment) throw std::runtime_error("Could not resolve fragment \"" + m_unresolvedFragmentName->texUtf8() + "\" in file " + m_unresolvedFragmentName->filePositionString());
        std::string returnString;
        documentPart::m_fileIndentation += m_leadingSpaces;
        std::string fragmentNameString;
        if(documentPart::m_commentStyle != outputFileFlags::NO_COMMENTS){
            for(const auto& m_referenceFragmentNamePart: *m_referenceFragmentName){
                fragmentNamePartDefinition* referenceNamePart = dynamic_cast<fragmentNamePartDefinition*>(m_referenceFragmentNamePart);
                filePosition ll_filePosition("",1,documentPart::m_fileIndentation+1,1,1);
                if(!referenceNamePart) 
                    throw std::runtime_error("Internal error, could not get fragment reference name correctly!");
                if(dynamic_cast<fragmentNamePartArgumentString*>(referenceNamePart))
                    fragmentNameString += "'" + referenceNamePart->utf8(ll_filePosition) + "'";
                else
                    fragmentNameString += referenceNamePart->fileUtf8(ll_filePosition);
            }
            if(documentPart::auxFileWasParsed()){
                std::string scrapNumber = auxFile::scrapId(m_fragment->scrapNumber());
                fragmentNameString += " " + scrapNumber;
            }
            else
                std::cout << "No aux file yet, need to run Latex again!\n";
        }
        if((indexableText::isCurrentLineIndented() && (l_filePosition.m_column == documentPart::m_fileIndentation))||(l_filePosition.m_column == 0)){
            switch(documentPart::m_commentStyle){
                case outputFileFlags::C_COMMENTS:
                    if(indexableText::isCurrentLineIndented())
                        returnString += indexableText::progressFilePosition(l_filePosition, "/* " + fragmentNameString + " */\n" + std::string(documentPart::m_fileIndentation,' '));
                    else
                        returnString += indexableText::progressFilePosition(l_filePosition,std::string(documentPart::m_fileIndentation,' ') + "/* " + fragmentNameString + " */\n");
                    indexableText::increaseCurrentLine();
                    break;
                case outputFileFlags::CPP_COMMENTS:
                    break;
                case outputFileFlags::PERL_COMMENTS:
                    break;
                case outputFileFlags::NO_COMMENTS:
                default:
                    break;
            }
        }
        returnString += m_fragment->fileUtf8(l_filePosition, m_referenceFragmentName);
        documentPart::m_fileIndentation -= m_leadingSpaces;
        return returnString;
    }
@| fileUtf8 @}
\subsubsection{resolveReferences}
\indexClassMethod{fragmentReference}{resolveReferences}
@d \classImplementation{fragmentReference}
@{@%
    void nuweb::fragmentReference::resolveReferences(void){
        m_leadingSpaces = this->leadingSpaces();
        if(!m_fragment){
            m_fragment = fragmentDefinition::fragmentFromFragmentName(m_unresolvedFragmentName);
            // This is inside the if(!m_fragment) because we only want to add the 
            // reference if we didn't do so already
            if(m_fragment)
            {
                //std::cout << "DEBUG " << this << " " << __LINE__ << " " << __FUNCTION__ << "\n";
                m_fragment->addReference(this);
            }
        }
        if(!m_fragment) throw std::runtime_error("Could not resolve fragment \"" + m_unresolvedFragmentName->texUtf8() + "\" in file " + m_unresolvedFragmentName->filePositionString());
        if(!m_expandReference) 
            m_fragment->addReferenceScrapNumber(m_scrapNumber);
        for(auto& fragmentNamePart: *m_referenceFragmentName){
            fragmentNamePartDefinition* fragmentArgument = dynamic_cast<fragmentNamePartDefinition*>(fragmentNamePart);
            if(fragmentArgument)
                fragmentArgument->resolveReferences();
        }
    }
@| resolveReferences @}
\subsubsection{resolveReferences2}
\indexClassMethod{fragmentReference}{resolveReferences2}
@d \classImplementation{fragmentReference}
@{@%
    void nuweb::fragmentReference::resolveReferences2(void){
        for(const auto& referenceFragmentNamePart: *m_referenceFragmentName)
            referenceFragmentNamePart->resolveReferences2();
        for(auto& fragmentNamePart: *m_referenceFragmentName){
            fragmentNamePartDefinition* fragmentArgument = dynamic_cast<fragmentNamePartDefinition*>(fragmentNamePart);
            if(fragmentArgument)
                fragmentArgument->resolveReferences2();
        }
    }
@| resolveReferences2 @}
\subsubsection{setExpandReference}
\indexClassMethod{fragmentReference}{setExpandReference}
@d \classImplementation{fragmentReference}
@{@%
    void nuweb::fragmentReference::setExpandReference(bool expandReference){
        m_expandReference = expandReference;
    }
@| setExpandReference @}
\subsubsection{getFragmentDefinition}
\indexClassMethod{fragmentReference}{getFragmentDefinition}
@d \classImplementation{fragmentReference}
@{@%
    nuweb::fragmentDefinition* nuweb::fragmentReference::getFragmentDefinition(void) const{
        return m_fragment;
    }
@| getFragmentDefinition @}
\subsubsection{getFragmentName}
\indexClassMethod{fragmentReference}{getFragmentName}
@d \classImplementation{fragmentReference}
@{@%
    nuweb::documentPart* nuweb::fragmentReference::getFragmentName(void) const{
       return m_referenceFragmentName; 
    }
@| getFragmentName @}
\subsubsection{getScrapNumber}
\indexClassMethod{fragmentReference}{getScrapNumber}
@d \classImplementation{fragmentReference}
@{@%
    unsigned int nuweb::fragmentReference::getScrapNumber(void) const{
        return m_scrapNumber;
    }
@| getScrapNumber @}
