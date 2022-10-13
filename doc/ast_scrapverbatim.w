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

\section{Class scrapVerbatim}
\subsection{Interface}
@d \classDeclaration{scrapVerbatim}
@{@%
class scrapVerbatim : public scrap {
public:
    scrapVerbatim(const scrapVerbatim&) = delete;
    scrapVerbatim(scrapVerbatim&& l_scrapVerbatim) : scrap(std::move(l_scrapVerbatim)){
    }
    scrapVerbatim(documentPart* l_documentPart) : scrap(l_documentPart) {
    }
    virtual std::string texUtf8(void) const override;
    bool resolveFragmentArguments(documentPart* fragmentName);
};
@}
\section{Implementation}
\subsubsection{texUtf8}
@d \classImplementation{scrapVerbatim}
@{@%
    std::string nuweb::scrapVerbatim::texUtf8(void) const{
        std::stringstream documentLines(documentPart::texUtf8());
        std::string documentLine;
        std::string returnString;
        bool b_readUntilEnd = false;
        if(listingsPackageEnabled()){
            while(std::getline(documentLines,documentLine)){
                returnString += "\\mbox{}\\lstinline@@" + documentLine + "@@\\\\\n";
                b_readUntilEnd = (documentLines.rdstate() == std::ios_base::eofbit);
            }
            if(!b_readUntilEnd)
                returnString += "\\mbox{}\\lstinline@@@@\\\\\n";
        }
        else{
            while(std::getline(documentLines,documentLine)){
                returnString += "\\mbox{}\\verb@@" + documentLine + "@@\\\\\n";
                b_readUntilEnd = (documentLines.rdstate() == std::ios_base::eofbit);
            }
            if(!b_readUntilEnd)
                returnString += "\\mbox{}\\verb@@@@\\\\\n";
        }
        returnString.pop_back();
        returnString.pop_back();
        returnString.pop_back();
        returnString += "{\\NWsep}\n";
        return returnString;
    }
@| texUtf8 @}
\subsubsection{resolveFragmentArguments}
@d \classImplementation{scrapVerbatim}
@{@%
    bool nuweb::scrapVerbatim::resolveFragmentArguments(documentPart* fragmentName){
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
                    std::cout << "Found fragment argument which needs expansion!\n";
                    unsigned int argumentNumber = foundFragmentArgument->number();
                    if(argumentNumber>fragmentNameArguments.size())
                        throw std::runtime_error("Referencing argument number " + std::to_string(argumentNumber) + " but there are only " + std::to_string(fragmentNameArguments.size()) + " arguments defined in this fragment!");
                    foundFragmentArgument->setNameToExpandTo(fragmentNameArguments.at(argumentNumber-1));
                    std::cout << "  expanded to \"" << fragmentNameArguments.at(argumentNumber-1)->texUtf8() << "\"";

                }
            }
        }
        else
            throw std::runtime_error("Internal error, unexpected empty argument list in scrapVerbatim::resolveFragmentArguments!");
        return true;
    }
@| resolveFragmentArguments @}
