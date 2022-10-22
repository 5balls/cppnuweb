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
    static std::map<std::string, std::vector<unsigned int> > m_userIdentifiersToScrapNumbers;
    static std::map<std::string, std::vector<unsigned int> > m_userIdentifiersToScrapsUsingThem;
public:
    userIdentifiers(filePosition* l_filePosition);
    userIdentifiers(documentPart&& l_documentPart);
    void setScrapNumber(unsigned int scrapNumber);
    static void setScrapUsingIdentifier(std::string identifier, unsigned int scrapNumber);
    static std::vector<std::pair<std::string, std::vector<unsigned int> > > uses(const std::string& textToCheck);
    static std::vector<std::pair<std::string, std::vector<unsigned int> > > defines(unsigned int scrapNumber);
    virtual std::string texUtf8(void) const override;
};
@| userIdentifiers @}

\subsection{Implementation}
@d \staticDefinitions{userIdentifier}
@{@%
std::map<std::string, std::vector<unsigned int> > nuweb::userIdentifiers::m_userIdentifiersToScrapNumbers = {};
std::map<std::string, std::vector<unsigned int> > nuweb::userIdentifiers::m_userIdentifiersToScrapsUsingThem = {};
@}
\subsubsection{uses}
\indexClassMethod{userIdentifiers}{uses}
@d \classImplementation{userIdentifiers}
@{@%
    std::vector<std::pair<std::string, std::vector<unsigned int> > > nuweb::userIdentifiers::uses(const std::string& textToCheck){
        std::vector<std::pair<std::string, std::vector<unsigned int> > > returnValue;
        for(auto const& [userIdentifier, scrapNumbers]: m_userIdentifiersToScrapNumbers)
            if(textToCheck.find(userIdentifier) != std::string::npos)
                returnValue.push_back({userIdentifier, scrapNumbers});
        return returnValue;
    }
@| uses @}
\subsubsection{defines}
\indexClassMethod{userIdentifiers}{defines}
@d \classImplementation{userIdentifiers}
@{@%
    std::vector<std::pair<std::string, std::vector<unsigned int> > > nuweb::userIdentifiers::defines(unsigned int scrapNumber){
        std::vector<std::pair<std::string, std::vector<unsigned int> > > returnValue;
        std::vector<std::string> identifiersDefinedByThisScrap;
        for(auto const& [userIdentifier, scrapNumbers]: m_userIdentifiersToScrapNumbers)
            if(std::find(scrapNumbers.begin(), scrapNumbers.end(), scrapNumber) != scrapNumbers.end()) identifiersDefinedByThisScrap.push_back(userIdentifier);
        for(auto const& identifier: identifiersDefinedByThisScrap)
            returnValue.push_back({identifier, m_userIdentifiersToScrapsUsingThem[identifier]});
        return returnValue; 
    }
@| defines @}
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
        std::vector<unsigned int>& scrapNumbers = m_userIdentifiersToScrapNumbers[utf8()];
        if(std::find(scrapNumbers.begin(), scrapNumbers.end(), scrapNumber) == scrapNumbers.end())
            scrapNumbers.push_back(scrapNumber);
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
\subsubsection{setScrapUsingIdentifier}
\indexClassMethod{userIdentifiers}{setScrapUsingIdentifier}
@d \classImplementation{userIdentifiers}
@{@%
    void nuweb::userIdentifiers::setScrapUsingIdentifier(std::string identifier, unsigned int scrapNumber){
        std::vector<unsigned int>& scrapNumbers = m_userIdentifiersToScrapsUsingThem[identifier];
        std::vector<unsigned int>& scrapNumbersDefiningIdentifiers = m_userIdentifiersToScrapNumbers[identifier];
        if(std::find(scrapNumbersDefiningIdentifiers.begin(), scrapNumbersDefiningIdentifiers.end(), scrapNumber) == scrapNumbersDefiningIdentifiers.end())
            if(std::find(scrapNumbers.begin(), scrapNumbers.end(), scrapNumber) == scrapNumbers.end())
                scrapNumbers.push_back(scrapNumber);
    
    }
@| setScrapUsingIdentifier @}
