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

\section{Class scrapVerbatimArgument}
\subsection{Interface}
@d \classDeclaration{scrapVerbatimArgument}
@{@%
class scrapVerbatimArgument : public fragmentNamePartDefinition, public scrapVerbatim {
private:
    static std::vector<scrapVerbatimArgument*> m_missingScrapNumbers;
protected:
public:
    unsigned int m_scrapNumber; 
    scrapVerbatimArgument(const scrapVerbatimArgument&) = delete;
    scrapVerbatimArgument(scrapVerbatimArgument&& l_scrapVerbatim) : scrapVerbatim(std::move(l_scrapVerbatim)){
        m_missingScrapNumbers.push_back(this);
    }
    scrapVerbatimArgument(documentPart* l_documentPart) : scrapVerbatim(l_documentPart){
        m_missingScrapNumbers.push_back(this);
    }
    virtual std::string utf8(filePosition& l_filePosition) const override;
    virtual std::string texUtf8(void) const override;
    static void setMissingScrapNumbers(void);
};
@| scrapVerbatimArgument @}

@d \staticDefinitions{scrapVerbatimArgument}
@{@%
std::vector<nuweb::scrapVerbatimArgument*> nuweb::scrapVerbatimArgument::m_missingScrapNumbers = {};
@}

\subsubsection{utf8}
\indexClassMethod{scrapVerbatimArgument}{utf8}
@d \classImplementation{scrapVerbatimArgument}
@{@%
    std::string nuweb::scrapVerbatimArgument::utf8(nuweb::filePosition& l_filePosition) const {
        return "";
       //return scrapVerbatim::utf8(l_filePosition); 
    }
@| utf8 @}
\subsubsection{texUtf8}
\indexClassMethod{scrapVerbatimArgument}{texUtf8}
@d \classImplementation{scrapVerbatimArgument}
@{@%
    std::string nuweb::scrapVerbatimArgument::texUtf8(void) const{
        std::string returnString = "\\verb@@";
        for(auto& scrapPart: *this){
            fragmentArgument* possibleFragmentArgument = dynamic_cast<fragmentArgument*>(scrapPart);
            filePosition ll_filePosition("",1,documentPart::m_fileIndentation+1,1,1);
            if(possibleFragmentArgument)
                returnString += scrapPart->fileUtf8(ll_filePosition);
            else
                returnString += scrapPart->texUtf8();
        }
        returnString += "@@ ";
        return returnString;
    }
@| texUtf8 @}
\subsubsection{setMissingScrapNumbers}
\indexClassMethod{scrapVerbatimArgument}{setMissingScrapNumbers}
@d \classImplementation{scrapVerbatimArgument}
@{@%
    void nuweb::scrapVerbatimArgument::setMissingScrapNumbers(void){
        for(auto& missingScrapNumber: m_missingScrapNumbers)
            missingScrapNumber->m_scrapNumber = fragmentDefinition::increaseScrapNumber();
        m_missingScrapNumbers.clear();
    }
@| setMissingScrapNumbers @}
