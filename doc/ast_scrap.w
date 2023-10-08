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

\section{Class scrap}
\subsection{Interface}
\indexClass{scrap}
@d \classDeclaration{scrap}
@{@%
class scrap : public documentPart {
public:
    scrap(const scrap&) = delete;
    scrap(scrap&& l_scrap) : documentPart(std::move(l_scrap)){
    }
    scrap(documentPart&& l_documentPart) : documentPart(std::move(l_documentPart)){
    }
    scrap(documentPart* l_documentPart) : documentPart(l_documentPart){
    }
    bool resolveFragmentArguments(const std::vector<std::string>& fragmentArgumentsExpanded, const std::vector<std::string>& fragmentArgumentsUnexpanded);
    void setUserIdentifiersScrapNumber(unsigned int scrapNumber);
    void setCrossReferencesScrapNumber(unsigned int scrapNumber);
    virtual std::string utf8(filePosition& l_filePosition) const override;
    virtual std::string fileUtf8(filePosition& l_filePosition) const override;
};
@| scrap @}

\subsection{Implementation}
\subsubsection{resolveFragmentArguments}
\indexClassMethod{fragmentDefinition}{resolveFragmentArguments}
@d \classImplementation{scrap}
@{@%
    bool nuweb::scrap::resolveFragmentArguments(const std::vector<std::string>& fragmentArgumentsExpanded, const std::vector<std::string>& fragmentArgumentsUnexpanded){
        if(!empty()){
            for(const auto& l_documentPart: *this){
                fragmentArgument* foundFragmentArgument = dynamic_cast<fragmentArgument*>(l_documentPart);
                if(foundFragmentArgument){
                    unsigned int argumentNumber = foundFragmentArgument->number();
                    if(argumentNumber>fragmentArgumentsExpanded.size())
                    {
                        std::cout << "  Referencing argument number " + std::to_string(argumentNumber) + " but there are only " + std::to_string(fragmentArgumentsExpanded.size()) + " arguments defined in this fragment!\n";
                        foundFragmentArgument->setNameToExpandTo("");
                    }
                    else
                        foundFragmentArgument->setNameToExpandTo(fragmentArgumentsExpanded.at(argumentNumber-1));
                }
                if(foundFragmentArgument){
                    unsigned int argumentNumber = foundFragmentArgument->number();
                    if(argumentNumber>fragmentArgumentsUnexpanded.size())
                    {
                        std::cout << "  Referencing unexpanded argument number " + std::to_string(argumentNumber) + " but there are only " + std::to_string(fragmentArgumentsUnexpanded.size()) + " unexpanded arguments defined in this fragment!\n";
                        foundFragmentArgument->setNameToUnexpandTo("");
                    }
                    else
                        foundFragmentArgument->setNameToUnexpandTo(fragmentArgumentsUnexpanded.at(argumentNumber-1));
                }

                fragmentReference* possibleFragmentReference = dynamic_cast<fragmentReference*>(l_documentPart);
                if(possibleFragmentReference)
                    possibleFragmentReference->setFragmentArgumentsExpanded(fragmentArgumentsExpanded, fragmentArgumentsUnexpanded);
            }
        }
        // Note: Empty scraps are possible and no reason to throw an error here
        return true;
    }
@| resolveFragmentArguments @}
\subsubsection{setUserIdentifiersScrapNumber}
\indexClassMethod{scrap}{setUserIdentifiersScrapNumber}
@d \classImplementation{scrap}
@{@%
    void nuweb::scrap::setUserIdentifiersScrapNumber(unsigned int scrapNumber){
       if(!empty())
           for(auto& documentPart: *this){
               userIdentifiers* userIdentifier = dynamic_cast<userIdentifiers*>(documentPart);
               if(userIdentifier){
                   if(userIdentifier->empty())
                       userIdentifier->setScrapNumber(scrapNumber);
                   else
                       for(auto& l_userIdentifier: *userIdentifier){
                           userIdentifiers* ll_userIdentifier = dynamic_cast<userIdentifiers*>(l_userIdentifier);
                           if(ll_userIdentifier)
                               ll_userIdentifier->setScrapNumber(scrapNumber);
                           else
                               throw std::runtime_error("Internal error, can not convert user identifier list to corresponding type!");
                       }
               }
           }
    }
@| setUserIdentifiersScrapNumber @}
\subsubsection{setCrossReferencesScrapNumber}
\indexClassMethod{scrap}{setCrossReferencesScrapNumber}
@d \classImplementation{scrap}
@{@%
    void nuweb::scrap::setCrossReferencesScrapNumber(unsigned int scrapNumber){
        if(!empty())
            for(auto& documentPart: *this){
                crossReference* l_crossReference = dynamic_cast<crossReference*>(documentPart);
                if(l_crossReference)
                    l_crossReference->setScrapNumber(scrapNumber);
            }
    }
@| setCrossReferencesScrapNumber @}
\subsubsection{utf8}
\indexClassMethod{scrap}{utf8}
@d \classImplementation{scrap}
@{@%
    std::string nuweb::scrap::utf8(filePosition& l_filePosition) const{
        if(empty())
            return documentPart::utf8(l_filePosition);
        else{
            std::string returnString;
            for(const auto& scrapPart: *this)
                if(!dynamic_cast<blockCommentReference*>(scrapPart))
                    returnString += scrapPart->utf8(l_filePosition);
            return returnString;
        }
    }
@| utf8 @}
\subsubsection{fileUtf8}
\indexClassMethod{scrap}{fileUtf8}
@d \classImplementation{scrap}
@{@%
    std::string nuweb::scrap::fileUtf8(filePosition& l_filePosition) const{
        // TODO Insert comment of unexpanded fragArgument before line
       if(empty())
           return documentPart::fileUtf8(l_filePosition); 
       else{
           std::string returnString;
           for(const auto& scrapPart: *this)
               if(!dynamic_cast<blockCommentReference*>(scrapPart))
                   returnString += scrapPart->fileUtf8(l_filePosition);
           return returnString;
       }
    }
@| fileUtf8 @}
