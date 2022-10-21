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

\section{Class userIdentifiers}
\subsection{Interface}
@d \classDeclaration{userIdentifiers}
@{@%
class userIdentifiers : public documentPart {
private:
    static std::map<std::string, unsigned int> m_userIdentifiersToScrapNumbers;
public:
    userIdentifiers(filePosition* l_filePosition);
    userIdentifiers(documentPart&& l_documentPart);
    void setScrapNumber(unsigned int scrapNumber);
    static std::vector<std::pair<std::string, unsigned int> > uses(const std::string& textToCheck);
    virtual std::string texUtf8(void) const override;
};
@| userIdentifiers @}

\subsection{Implementation}
@d \staticDefinitions{userIdentifier}
@{@%
std::map<std::string, unsigned int> nuweb::userIdentifiers::m_userIdentifiersToScrapNumbers = {};
@}
\subsubsection{uses}
\indexClassMethod{userIdentifiers}{uses}
@d \classImplementation{userIdentifiers}
@{@%
    std::vector<std::pair<std::string, unsigned int> > nuweb::userIdentifiers::uses(const std::string& textToCheck){
        std::vector<std::pair<std::string, unsigned int> > returnValue;
       for(auto const& [userIdentifier, scrapNumber]: m_userIdentifiersToScrapNumbers)
           if(textToCheck.find(userIdentifier) != std::string::npos)
               returnValue.push_back({userIdentifier, scrapNumber});
       return returnValue;
    }
@| uses @}
\subsubsection{userIdentifiers}
\indexClassMethod{userIdentifiers}{userIdentifiers}
@d \classImplementation{userIdentifiers}
@{@%
    nuweb::userIdentifiers::userIdentifiers(filePosition* l_filePosition) : documentPart(l_filePosition){
        
    }
@| userIdentifiers @}
\subsubsection{setScrapNumber}
\indexClassMethod{userIdentifiers}{setScrapNumber}
@d \classImplementation{userIdentifiers}
@{@%
    void nuweb::userIdentifiers::setScrapNumber(unsigned int scrapNumber){
        m_userIdentifiersToScrapNumbers[utf8()] = scrapNumber;
    }
@| setScrapNumber @}
\subsubsection{texUtf8}
\indexClassMethod{userIdentifiers}{texUtf8}
@d \classImplementation{userIdentifiers}
@{@%
    std::string nuweb::userIdentifiers::texUtf8(void) const{
       return "";
    }
@| texUtf8 @}
