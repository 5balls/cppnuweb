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
