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

\section{Class fragmentNamePartArgumentString}
\subsection{Interface}
@d \classDeclaration{fragmentNamePartArgumentString}
@{@%
class fragmentNamePartArgumentString : public fragmentNamePartArgument {
private:
    
public:
    fragmentNamePartArgumentString(filePosition* l_filePosition);
    fragmentNamePartArgumentString(documentPart&& l_documentPart);
    virtual std::string texUtf8(void) const override;
    virtual void resolveReferences2(void) override;
};
@| fragmentNamePartArgumentString @}
\subsubsection{fragmentNamePartArgumentString}
\indexClassMethod{fragmentNamePartArgumentString}{fragmentNamePartArgumentString}
@d \classImplementation{fragmentNamePartArgumentString}
@{@%
     nuweb::fragmentNamePartArgumentString::fragmentNamePartArgumentString(filePosition* l_filePosition) : fragmentNamePartArgument(l_filePosition) {
        
    }
@| fragmentNamePartArgumentString @}
\subsubsection{fragmentNamePartArgumentString}
\indexClassMethod{fragmentNamePartArgumentString}{fragmentNamePartArgumentString}
@d \classImplementation{fragmentNamePartArgumentString}
@{@%
     nuweb::fragmentNamePartArgumentString::fragmentNamePartArgumentString(documentPart&& l_documentPart) : fragmentNamePartArgument(std::move(l_documentPart)){
        
    }
@| fragmentNamePartArgumentString @}
\subsubsection{texUtf8}
\indexClassMethod{fragmentNamePartArgumentString}{texUtf8}
@d \classImplementation{fragmentNamePartArgumentString}
@{@%
    std::string nuweb::fragmentNamePartArgumentString::texUtf8(void) const{
        filePosition ll_filePosition("",1,documentPart::m_fileIndentation+1,1,1);
        return "\\hbox{\\slshape\\sffamily " + utf8(ll_filePosition) + "\\/}";
    }
@| texUtf8 @}
\subsubsection{resolveReferences2}
\indexClassMethod{fragmentNamePartArgumentString}{resolveReferences2}
@d \classImplementation{fragmentNamePartArgumentString}
@{@%
    void nuweb::fragmentNamePartArgumentString::resolveReferences2(void){
        if(!m_parent)
            throw std::runtime_error("Internal error, fragmentNamePartArgumentString::m_parent not set!");
        fragmentDefinition* correspondingFragmentDefinition = dynamic_cast<fragmentDefinition*>(m_parent);
        unsigned int scrapNumber;
        if(correspondingFragmentDefinition){
            scrapNumber = correspondingFragmentDefinition->scrapNumber();
        }
        else{
            fragmentReference* parentReference = dynamic_cast<fragmentReference*>(m_parent);
            if(!parentReference)
                throw std::runtime_error("Could not resolve shortened fragment argument!");
            scrapNumber = parentReference->getScrapNumber();
        }
        std::vector<std::pair<std::string, std::vector<unsigned int> > > usedIdentifiersInFragment;
        filePosition ll_filePosition("",1,documentPart::m_fileIndentation+1,1,1);
        usedIdentifiersInFragment = userIdentifiers::uses(utf8(ll_filePosition));
        for(auto& usedIdentifier: usedIdentifiersInFragment)
            userIdentifiers::setScrapUsingIdentifier(usedIdentifier.first, scrapNumber);
    }
@| resolveReferences2 @}
