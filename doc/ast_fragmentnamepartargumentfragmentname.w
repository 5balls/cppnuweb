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

\section{Class fragmentNamePartArgumentFragmentName}
\subsection{Interface}
@d \classDeclaration{fragmentNamePartArgumentFragmentName}
@{@%
class fragmentNamePartArgumentFragmentName : public fragmentNamePartArgument {
private:
    fragmentReference* m_fragmentReference;
    bool m_global;
public:
    fragmentNamePartArgumentFragmentName(fragmentReference* l_fragmentReference);
    virtual std::string utf8(filePosition& l_filePosition) const override;
    virtual std::string texUtf8(void) const override;
    virtual std::string fileUtf8(filePosition& l_filePosition) const override;
    virtual void resolveReferences(void) override;
    virtual void resolveReferences2(void) override;
    void setGlobal(void);
};
@| fragmentNamePartArgumentFragmentName @}
\subsubsection{fragmentNamePartArgumentFragmentName}
\indexClassMethod{fragmentNamePartArgumentFragmentName}{fragmentNamePartArgumentFragmentName}
@d \classImplementation{fragmentNamePartArgumentFragmentName}
@{@%
     nuweb::fragmentNamePartArgumentFragmentName::fragmentNamePartArgumentFragmentName(fragmentReference* l_fragmentReference) : fragmentNamePartArgument(documentPart()), m_fragmentReference(l_fragmentReference), m_global(false){
    }
@| fragmentNamePartArgumentFragmentName @}
\subsubsection{utf8}
\indexClassMethod{fragmentNamePartArgumentFragmentName}{utf8}
@d \classImplementation{fragmentNamePartArgumentFragmentName}
@{@%
    std::string nuweb::fragmentNamePartArgumentFragmentName::utf8(filePosition& l_filePosition) const{
        if(!m_fragmentReference)
            throw std::runtime_error("Internal error, unresolved fragmentNamePartArgumentFragmentName!");
        documentPart* l_referenceFragmentName = m_fragmentReference->getFragmentName();
        if(!l_referenceFragmentName)
            throw std::runtime_error("Internal error, could not get fragment name in fragmentNamePartArgumentFragmentName!");
        std::string returnString;
        std::string fragmentNameString;
        for(const auto& m_referenceFragmentNamePart: *l_referenceFragmentName){
            filePosition ll_filePosition("",1,documentPart::m_fileIndentation+1,1,1);
            fragmentNamePartDefinition* referenceNamePart = dynamic_cast<fragmentNamePartDefinition*>(m_referenceFragmentNamePart);
            if(!referenceNamePart) 
                throw std::runtime_error("Internal error, could not get fragment reference name correctly!");
            if(dynamic_cast<fragmentNamePartArgumentString*>(referenceNamePart))
                fragmentNameString += "'" + m_referenceFragmentNamePart->utf8(ll_filePosition) + "'";
            else
                fragmentNameString += m_referenceFragmentNamePart->fileUtf8(ll_filePosition);
        }
        return indexableText::progressFilePosition(l_filePosition, "<" + fragmentNameString + ">");
    }
@| utf8 @}
\subsubsection{texUtf8}
\indexClassMethod{fragmentNamePartArgumentFragmentName}{texUtf8}
@d \classImplementation{fragmentNamePartArgumentFragmentName}
@{@%
    std::string nuweb::fragmentNamePartArgumentFragmentName::texUtf8(void) const{
        if(!m_fragmentReference)
            throw std::runtime_error("Internal error, unresolved fragmentNamePartArgumentFragmentName!");
        std::string returnString = "$\\langle\\,${\\itshape ";
        documentPart* l_referenceFragmentName = m_fragmentReference->getFragmentName();
        if(!l_referenceFragmentName)
            throw std::runtime_error("Internal error, could not get fragment name in fragmentNamePartArgumentFragmentName!");
        for(const auto& referenceFragmentNamePart: *l_referenceFragmentName){
            fragmentNamePartDefinition* referenceNamePart = dynamic_cast<fragmentNamePartDefinition*>(referenceFragmentNamePart);
            if(!referenceNamePart) 
                throw std::runtime_error("Internal error, could not get fragment reference name correctly!");
            if(dynamic_cast<fragmentNamePartArgumentString*>(referenceNamePart)){
                filePosition ll_filePosition("",1,documentPart::m_fileIndentation+1,1,1);
                if(listingsPackageEnabled())
                    returnString += "\\lstinline@@" + referenceFragmentNamePart->utf8(ll_filePosition) + "@@";
                else
                    returnString += "\\verb@@" + referenceFragmentNamePart->utf8(ll_filePosition) + "@@";
            }
            else
                returnString += referenceFragmentNamePart->texUtf8();
        }
        returnString += "}\\nobreak\\ {\\footnotesize \\NWlink{nuweb";
        std::string scrapNumber = "?";
        fragmentDefinition* fragment = m_fragmentReference->getFragmentDefinition();
        if(!fragment)
            throw std::runtime_error("Internal error, could not get fragment definition in fragmentNamePartArgumentFragmentName!");
        if(documentPart::auxFileWasParsed())
            scrapNumber = auxFile::scrapId(fragment->scrapNumber());
        else
            std::cout << "No aux file yet, need to run Latex again!\n";
        returnString += scrapNumber + "}{" + scrapNumber + "}";
        if(fragment->scrapsFromFragment().size() > 1)
            returnString += ", \\ldots\\ ";
        if(listingsPackageEnabled())
            returnString += "}$\\,\\rangle$";
        else
            returnString += "}$\\,\\rangle$";
        return returnString;
    }
@| texUtf8 @}
\subsubsection{fileUtf8}
\indexClassMethod{fragmentNamePartArgumentFragmentName}{fileUtf8}
@d \classImplementation{fragmentNamePartArgumentFragmentName}
@{@%
    std::string nuweb::fragmentNamePartArgumentFragmentName::fileUtf8(filePosition& l_filePosition) const{
        if(!m_fragmentReference)
            throw std::runtime_error("Internal error, unresolved fragmentNamePartArgumentFragmentName!");
        documentPart* l_referenceFragmentName = m_fragmentReference->getFragmentName();
        if(!l_referenceFragmentName)
            throw std::runtime_error("Internal error, could not get fragment name in fragmentNamePartArgumentFragmentName!");
        std::string returnString;
        std::string fragmentNameString;
        for(const auto& m_referenceFragmentNamePart: *l_referenceFragmentName){
            filePosition ll_filePosition("",1,documentPart::m_fileIndentation+1,1,1);
            fragmentNamePartDefinition* referenceNamePart = dynamic_cast<fragmentNamePartDefinition*>(m_referenceFragmentNamePart);
            if(!referenceNamePart) 
                throw std::runtime_error("Internal error, could not get fragment reference name correctly!");
            if(dynamic_cast<fragmentNamePartArgumentString*>(referenceNamePart))
                fragmentNameString += "'" + m_referenceFragmentNamePart->utf8(ll_filePosition) + "'";
            else
                fragmentNameString += m_referenceFragmentNamePart->fileUtf8(ll_filePosition);
        }
        //if((indexableText::isCurrentLineIndented() && (l_filePosition.m_column == documentPart::m_fileIndentation))||(l_filePosition.m_column == 0)){
            switch(documentPart::m_commentStyle){
                case outputFileFlags::C_COMMENTS:
                    if(indexableText::isCurrentLineIndented())
                        returnString += indexableText::progressFilePosition(l_filePosition, "/* " + fragmentNameString + " */\n" + std::string(documentPart::m_fileIndentation,' '));
                    else
                        returnString += indexableText::progressFilePosition(l_filePosition,std::string(documentPart::m_fileIndentation,' ') + "/* " + fragmentNameString + " */\n");
                    indexableText::increaseCurrentLine();
                    break;
                case outputFileFlags::CPP_COMMENTS:
                    if(indexableText::isCurrentLineIndented())
                        returnString += indexableText::progressFilePosition(l_filePosition, "// " + fragmentNameString + "\n" + std::string(documentPart::m_fileIndentation,' '));
                    else
                        returnString += indexableText::progressFilePosition(l_filePosition,std::string(documentPart::m_fileIndentation,' ') + "// " + fragmentNameString + "\n");
                    indexableText::increaseCurrentLine();
                    break;
                case outputFileFlags::PERL_COMMENTS:
                    if(indexableText::isCurrentLineIndented())
                        returnString += indexableText::progressFilePosition(l_filePosition, "# " + fragmentNameString + "\n" + std::string(documentPart::m_fileIndentation,' '));
                    else
                        returnString += indexableText::progressFilePosition(l_filePosition,std::string(documentPart::m_fileIndentation,' ') + "# " + fragmentNameString + "\n");
                    indexableText::increaseCurrentLine();
                    break;

                    break;
                case outputFileFlags::NO_COMMENTS:
                default:
                    break;
            }
        //}
        fragmentDefinition* fragment = m_fragmentReference->getFragmentDefinition();
        returnString += fragment->fileUtf8(l_filePosition); 
        return returnString;
    }
@| fileUtf8 @}
\subsubsection{resolveReferences}
\indexClassMethod{fragmentNamePartArgumentFragmentName}{resolveReferences}
@d \classImplementation{fragmentNamePartArgumentFragmentName}
@{@%
    void nuweb::fragmentNamePartArgumentFragmentName::resolveReferences(void){
        if(m_fragmentReference)
            m_fragmentReference->resolveReferences();
        else
            throw std::runtime_error("Internal error, unresolved fragmentNamePartArgumentFragmentName!");
    }
@| resolveReferences @}
\subsubsection{resolveReferences2}
\indexClassMethod{fragmentNamePartArgumentFragmentName}{resolveReferences2}
@d \classImplementation{fragmentNamePartArgumentFragmentName}
@{@%
    void nuweb::fragmentNamePartArgumentFragmentName::resolveReferences2(void){
        if(!m_fragmentReference)
            throw std::runtime_error("Internal error, unresolved fragmentNamePartArgumentFragmentName!");
        documentPart* l_referenceFragmentName = m_fragmentReference->getFragmentName();
        if(!l_referenceFragmentName)
            throw std::runtime_error("Internal error, could not get fragment name in fragmentNamePartArgumentFragmentName!");
        std::string stringWithPossibleUserIdentifiers;
        for(const auto& referenceFragmentNamePart: *l_referenceFragmentName){
            fragmentNamePartDefinition* referenceNamePart = dynamic_cast<fragmentNamePartDefinition*>(referenceFragmentNamePart);
            if(!referenceNamePart) 
                throw std::runtime_error("Internal error, could not get fragment reference name correctly!");
            if(dynamic_cast<fragmentNamePartArgumentString*>(referenceNamePart)){
                filePosition ll_filePosition("",1,documentPart::m_fileIndentation+1,1,1);
                stringWithPossibleUserIdentifiers += referenceFragmentNamePart->utf8(ll_filePosition);
            }
            else
                stringWithPossibleUserIdentifiers += referenceFragmentNamePart->texUtf8();
        }
        std::vector<std::pair<std::string, std::vector<unsigned int> > > usedIdentifiersInFragment;
        usedIdentifiersInFragment = userIdentifiers::uses(stringWithPossibleUserIdentifiers);
        for(auto& usedIdentifier: usedIdentifiersInFragment)
            userIdentifiers::setScrapUsingIdentifier(usedIdentifier.first, m_fragmentReference->getScrapNumber());
        m_fragmentReference->resolveReferences2();
    }
@| resolveReferences2 @}
\subsubsection{setGlobal}
\indexClassMethod{fragmentNamePartArgumentFragmentName}{setGlobal}
@d \classImplementation{fragmentNamePartArgumentFragmentName}
@{@%
    void nuweb::fragmentNamePartArgumentFragmentName::setGlobal(void){
        m_global = true;
    }
@| setGlobal @}
