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
@d \classDeclaration{scrap}
@{@%
class scrap : public documentPart {
public:
    scrap(const scrap&) = delete;
    scrap(scrap&& l_scrap) : documentPart(std::move(l_scrap)){
    }
    scrap(documentPart* l_documentPart) : documentPart(l_documentPart){
    }
    std::vector<std::pair<std::string, unsigned int> > uses(void);
    bool resolveFragmentArguments(documentPart* fragmentName);
    void setUserIdentifiersScrapNumber(unsigned int scrapNumber);
};
@| scrap @}

\subsection{Implementation}
\subsubsection{resolveFragmentArguments}
\indexClassMethod{fragmentDefinition}{resolveFragmentArguments}
@d \classImplementation{scrap}
@{@%
    bool nuweb::scrap::resolveFragmentArguments(documentPart* fragmentName){
        if(fragmentName->empty()) return false;
        std::vector<fragmentNamePartDefinition*> fragmentNameArguments;
        for(auto& fragmentNamePart: *fragmentName){
            fragmentNamePartDefinition* fragmentNamePossibleArgument = dynamic_cast<fragmentNamePartDefinition*>(fragmentNamePart);
            if(!fragmentNamePossibleArgument)
                throw std::runtime_error("Internal error, could not convert argument to argument type!");
            if(fragmentNamePossibleArgument->isArgument()) fragmentNameArguments.push_back(fragmentNamePossibleArgument);
        }
        if(!empty()){
            for(const auto& documentPart: *this){
                fragmentArgument* foundFragmentArgument = dynamic_cast<fragmentArgument*>(documentPart);
                if(foundFragmentArgument){
                    unsigned int argumentNumber = foundFragmentArgument->number();
                    if(argumentNumber>fragmentNameArguments.size())
                        throw std::runtime_error("Referencing argument number " + std::to_string(argumentNumber) + " but there are only " + std::to_string(fragmentNameArguments.size()) + " arguments defined in this fragment!");
                    foundFragmentArgument->setNameToExpandTo(fragmentNameArguments.at(argumentNumber-1));

                }
            }
        }
        else
            throw std::runtime_error("Internal error, unexpected empty argument list in scrap::resolveFragmentArguments!");
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
\subsubsection{uses}
\indexClassMethod{scrap}{uses}
@d \classImplementation{scrap}
@{@%
    std::vector<std::pair<std::string, unsigned int> > nuweb::scrap::uses(void){
        std::string scrapContent;
        if(empty())
            scrapContent = utf8();
        else
            for(const auto scrapContentPart: *this)
                scrapContent += scrapContentPart->utf8();
        return nuweb::userIdentifiers::uses(scrapContent);
    }
@| uses @}
