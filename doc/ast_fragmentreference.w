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
public:
    fragmentReference(documentPart* fragmentName);
    virtual std::string utf8(void) const override;
    virtual std::string texUtf8(void) const override;
    virtual std::string fileUtf8(void) const override;
    virtual void resolveReferences(void) override;
};
@}

\subsection{Implementation}
\subsubsection{fragmentReference}
@d \classImplementation{fragmentReference}
@{@%
    nuweb::fragmentReference::fragmentReference(documentPart* fragmentName) : m_unresolvedFragmentName(nullptr), m_referenceFragmentName(fragmentName){
        m_fragment = fragmentDefinition::fragmentFromFragmentName(fragmentName);
        if(!m_fragment) m_unresolvedFragmentName = fragmentName;
        m_scrapNumber = fragmentDefinition::totalNumberOfScraps() + 1;
        if(m_fragment) m_fragment->addReferenceScrapNumber(m_scrapNumber);
    }
@}
\subsubsection{texUtf8}
@d \classImplementation{fragmentReference}
@{@%
    std::string nuweb::fragmentReference::texUtf8(void) const{
        if(!m_fragment) throw std::runtime_error("Could not resolve fragment \"" + m_unresolvedFragmentName->texUtf8() + "\" in file " + m_unresolvedFragmentName->filePositionString());
        std::string returnString = "@@\\hbox{$\\langle\\,${\\itshape ";
        for(const auto& m_referenceFragmentNamePart: *m_referenceFragmentName){
            fragmentNamePartDefinition* referenceNamePart = dynamic_cast<fragmentNamePartDefinition*>(m_referenceFragmentNamePart);
            if(!referenceNamePart) 
                throw std::runtime_error("Internal error, could not get fragment reference name correctly!");
            if(referenceNamePart->isArgument())
                returnString += "\\verb@@" + referenceNamePart->utf8() + "@@";
            else
                returnString += referenceNamePart->utf8();
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
@}
\subsubsection{utf8}
@d \classImplementation{fragmentReference}
@{@%
    std::string nuweb::fragmentReference::utf8(void) const{
        fragmentDefinition* fragment = m_fragment;
        if(!fragment) fragment = fragmentDefinition::fragmentFromFragmentName(m_unresolvedFragmentName);
        if(!fragment) throw std::runtime_error("Could not resolve fragment \"" + m_unresolvedFragmentName->texUtf8() + "\" in file " + m_unresolvedFragmentName->filePositionString());
        fragment->addReferenceScrapNumber(m_scrapNumber);
        return fragment->utf8();
    }
@}
\subsubsection{fileUtf8}
@d \classImplementation{fragmentReference}
@{@%
    std::string nuweb::fragmentReference::fileUtf8(void) const{
        if(!m_fragment) throw std::runtime_error("Could not resolve fragment \"" + m_unresolvedFragmentName->texUtf8() + "\" in file " + m_unresolvedFragmentName->filePositionString());
        return m_fragment->fileUtf8(m_referenceFragmentName);
    }
@| fileUtf8 @}
\subsubsection{resolveReferences}
\indexClassMethod{fragmentReference}{resolveReferences}
@d \classImplementation{fragmentReference}
@{@%
    void nuweb::fragmentReference::resolveReferences(void){
        if(!m_fragment) m_fragment = fragmentDefinition::fragmentFromFragmentName(m_unresolvedFragmentName);
        if(!m_fragment) throw std::runtime_error("Could not resolve fragment \"" + m_unresolvedFragmentName->texUtf8() + "\" in file " + m_unresolvedFragmentName->filePositionString());
        m_fragment->addReferenceScrapNumber(m_scrapNumber);
    }
@| resolveReferences @}
