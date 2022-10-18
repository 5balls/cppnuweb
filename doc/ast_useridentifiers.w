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
    static std::vector<std::pair<std::string, unsigned int> > uses(std::string textToCheck) const;
    userIdentifiers(filePosition* l_filePosition);
    userIdentifiers(documentPart&& l_documentPart);
    virtual std::string texUtf8(void) const override;
};
@| userIdentifiers @}

\subsection{Implementation}
\subsubsection{uses}
\indexClassMethod{userIdentifier}{uses}
@d \classImplementation{userIdentifier}
@{@%
    std::vector<std::pair<std::string, unsigned int> > nuweb::userIdentifier::uses(std::string textToCheck){
        std::vector<std::pair<std::string, unsigned int> > returnValue;
       for(auto const& [userIdentifier, scrapNumber]: m_userIdentifiersToScrapNumbers)
           if(textToCheck.find(userIdentifier) != string::npos)
               returnValue.push_back({userIdentifier, scrapNumber});
       return returnValue;
    }
@| uses @}
