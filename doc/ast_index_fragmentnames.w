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

\section{Class indexFragmentNames}
\subsection{Interface}
@d \classDeclaration{indexFragmentNames}
@{@%
class indexFragmentNames : public documentPart{
private:
    unsigned int m_indexSectionLevel;
public:
    indexFragmentNames(filePosition* l_filePosition);
    virtual std::string texUtf8(void) const override;
};
@| indexFragmentNames @}
\section{Implementation}
\subsubsection{indexFragmentNames}
\indexClassMethod{indexFragmentNames}{indexFragmentNames}
@d \classImplementation{indexFragmentNames}
@{@%
    nuweb::indexFragmentNames::indexFragmentNames(filePosition* l_filePosition) : documentPart(l_filePosition), m_indexSectionLevel(m_sectionLevel){
    }
@| indexFragmentNames @}
\subsubsection{texUtf8}
\indexClassMethod{indexFragmentNames}{texUtf8}
@d \classImplementation{indexFragmentNames}
@{@%
    std::string nuweb::indexFragmentNames::texUtf8(void) const{
        std::string returnString;
        returnString = "\n{\\small\\begin{list}{}{\\setlength{\\itemsep}{-\\parsep}\\setlength{\\itemindent}{-\\leftmargin}}";
        std::vector<documentPart*> fragmentNames = fragmentDefinition::fragmentDefinitionsNames(m_indexSectionLevel);
        std::vector<unsigned int> scrapNumbers = fragmentDefinition::fragmentDefinitionsScrapNumbers(m_indexSectionLevel);
        std::vector<fragmentDefinition*> firstFragments = fragmentDefinition::fragmentDefinitionsFirstFragments(m_indexSectionLevel);
        unsigned int fragmentDefinitionNumber = 0;
        fragmentDefinition* lastFirstFragment = nullptr;
        std::string referenceString;
        unsigned int lastFragmentPage = 0;
        for(const auto& fragmentName: fragmentNames){
            std::string fragmentScrapId = auxFile::scrapId(scrapNumbers.at(fragmentDefinitionNumber));
            unsigned int currentFragmentPage = auxFile::scrapPage(scrapNumbers.at(fragmentDefinitionNumber));
            if(fragmentScrapId.empty()) fragmentScrapId = "?";
            if(firstFragments.at(fragmentDefinitionNumber) != lastFirstFragment){
                if(lastFirstFragment != nullptr){
                    returnString += "}$\\,\\rangle$ {\\footnotesize ";
                    returnString += referenceString;
                }
                lastFirstFragment = firstFragments.at(fragmentDefinitionNumber);
                returnString += "\n\\item $\\langle\\,$"+ fragmentName->texUtf8() + "\\nobreak\\ {\\footnotesize ";
                std::vector<unsigned int> referencesInScraps = firstFragments.at(fragmentDefinitionNumber)->referencesInScraps();
                bool multipleReferences = false;
                if(referencesInScraps.empty())
                    referenceString = "{\\NWtxtNoRef}";
                else{
                    referenceString = "{\\NWtxtRefIn} ";
                    unsigned int lastPage = 0;
                    for(const auto & referenceInScrap: referencesInScraps){
                        std::string scrapId = auxFile::scrapId(referenceInScrap);
                        unsigned int currentPage = auxFile::scrapPage(referenceInScrap);
                        referenceString += "\\NWlink{nuweb" + scrapId + "}{";
                        if(lastPage == 0){
                            referenceString += scrapId + "}";
                            lastPage = currentPage;
                            continue;
                        }
                        multipleReferences = true;
                        if(currentPage != lastPage){
                            referenceString += ", " + scrapId + "}";
                            lastPage = currentPage;
                            continue;
                        }
                        referenceString += std::string(1, auxFile::scrapLetter(referenceInScrap)) + "}";
                        lastPage = currentPage;
                    }
                }
                referenceString += ".";
                if(multipleReferences)
                    referenceString += "\n";
            }
            returnString += "\\NWlink{nuweb" + fragmentScrapId + "}{";
            if(lastFragmentPage == 0)
                returnString += fragmentScrapId + "}";
            else if(currentFragmentPage != lastFragmentPage)
                returnString += ", " + fragmentScrapId + "}";
            else
                returnString += std::string(1, auxFile::scrapLetter(scrapNumbers.at(fragmentDefinitionNumber))) + "}";
            lastFragmentPage = currentFragmentPage;
            fragmentDefinitionNumber++;
        }
        returnString += "}$\\,\\rangle$ {\\footnotesize ";
        returnString += referenceString;
        returnString += "}\n\\end{list}}\n"; 
        return returnString;
    }
@| texUtf8 @}
