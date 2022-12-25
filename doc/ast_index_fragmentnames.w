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
    bool m_global;
public:
    indexFragmentNames(filePosition* l_filePosition);
    virtual std::string texUtf8(void) const override;
    void setGlobal(void);
};
@| indexFragmentNames @}
\section{Implementation}
\subsubsection{indexFragmentNames}
\indexClassMethod{indexFragmentNames}{indexFragmentNames}
@d \classImplementation{indexFragmentNames}
@{@%
    nuweb::indexFragmentNames::indexFragmentNames(filePosition* l_filePosition) : documentPart(l_filePosition), m_indexSectionLevel(m_sectionLevel), m_global(false){
    }
@| indexFragmentNames @}
\subsubsection{texUtf8}
\indexClassMethod{indexFragmentNames}{texUtf8}
@d \classImplementation{indexFragmentNames}
@{@%
    std::string nuweb::indexFragmentNames::texUtf8(void) const{
        std::string returnString;
        returnString = "\n{\\small\\begin{list}{}{\\setlength{\\itemsep}{-\\parsep}\\setlength{\\itemindent}{-\\leftmargin}";

        std::vector<std::tuple<documentPart*, unsigned int, fragmentDefinition*> > fragmentNamesScrapNumbersFirstFragments = fragmentDefinition::fragmentDefinitionsNamesScrapNumbersFirstFragments(m_indexSectionLevel, m_global);
        std::vector<unsigned int> scrapNumbers = fragmentDefinition::fragmentDefinitionsScrapNumbers(m_indexSectionLevel, m_global);

        std::sort(fragmentNamesScrapNumbersFirstFragments.begin(), fragmentNamesScrapNumbersFirstFragments.end(), [](const std::tuple<documentPart*, unsigned int, fragmentDefinition*>& l_a, const std::tuple<documentPart*, unsigned int, fragmentDefinition*>& l_b){
                std::string a = std::get<0>(l_a)->texUtf8();
                std::string b = std::get<0>(l_b)->texUtf8();
                unsigned int charToCompareA = 0;
                unsigned int charToCompareB = 0;
                while((charToCompareA < a.size()) && (charToCompareB < b.size())){
                    while(a.at(charToCompareA)=='|' && (charToCompareA < a.size()-1))
                        charToCompareA++;
                    while(b.at(charToCompareB)=='|' && (charToCompareB < b.size()-1))
                        charToCompareB++;
                    if(std::tolower(a.at(charToCompareA)) != std::tolower(b.at(charToCompareB)))
                        return std::tolower(a.at(charToCompareA)) < std::tolower(b.at(charToCompareB));
                    charToCompareA++;
                    charToCompareB++;
                }
                if(a.size() != b.size())
                    return a.size() < b.size();
                charToCompareA = 0;
                charToCompareB = 0;
                while((charToCompareA < a.size()) && (charToCompareB < b.size())){
                    // Lowercase is equal, char not equal:
                    while(a.at(charToCompareA)=='|' && (charToCompareA < a.size()-1))
                        charToCompareA++;
                    while(b.at(charToCompareB)=='|' && (charToCompareB < b.size()-1))
                        charToCompareB++;
                    if(a.at(charToCompareA) != b.at(charToCompareB))
                        return a.at(charToCompareA) < b.at(charToCompareB);
                    charToCompareA++;
                    charToCompareB++;
                }
                return true;

                });
        unsigned int fragmentDefinitionNumber = 0;
        fragmentDefinition* lastFirstFragment = nullptr;
        std::string referenceString;
        unsigned int lastFragmentPage = 0;
        for(const auto& fragmentNameScrapNumberFirstFragment: fragmentNamesScrapNumbersFirstFragments){
            unsigned int scrapNumber = scrapNumbers.at(fragmentDefinitionNumber);
            if(std::get<2>(fragmentNameScrapNumberFirstFragment)->global() != m_global){
                continue;
            }
            std::string fragmentScrapId = "?";
            unsigned int currentFragmentPage = 1;
            if(auxFileWasParsed()){
                fragmentScrapId = auxFile::scrapId(scrapNumber);
                currentFragmentPage = auxFile::scrapPage(scrapNumber);
            }
            if(std::get<2>(fragmentNameScrapNumberFirstFragment) != lastFirstFragment){
                lastFragmentPage = 0;
                if(lastFirstFragment != nullptr){
                    returnString += "}$\\,\\rangle$ {\\footnotesize ";
                    returnString += referenceString;
                }
                lastFirstFragment = std::get<2>(fragmentNameScrapNumberFirstFragment);
                returnString += "}\n\\item $\\langle\\,$"+ std::get<0>(fragmentNameScrapNumberFirstFragment)->texUtf8() + "\\nobreak\\ {\\footnotesize ";
                std::vector<unsigned int> referencesInScraps = std::get<2>(fragmentNameScrapNumberFirstFragment)->referencesInScraps();
                bool multipleReferences = false;
                if(referencesInScraps.empty())
                    referenceString = "{\\NWtxtNoRef}";
                else{
                    referenceString = "{\\NWtxtRefIn} ";
                    unsigned int lastPage = 0;
                    for(const auto & referenceInScrap: referencesInScraps){
                        std::string scrapId = "?"; 
                        unsigned int currentPage = 1;
                        if(auxFileWasParsed()){
                            scrapId = auxFile::scrapId(referenceInScrap);
                            currentPage = auxFile::scrapPage(referenceInScrap);
                        }
                        referenceString += "\\NWlink{nuweb" + scrapId + "}{";
                        if(lastPage == 0){
                            referenceString += scrapId + "}";
                            if(!auxFileWasParsed())
                                lastPage++;
                            else
                                lastPage = currentPage;
                            continue;
                        }
                        multipleReferences = true;
                        if(currentPage != lastPage || !auxFileWasParsed()){
                            referenceString += ", " + scrapId + "}";
                            if(!auxFileWasParsed())
                                lastPage++;
                            else
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
            else if(currentFragmentPage != lastFragmentPage || !auxFileWasParsed())
                returnString += ", " + fragmentScrapId + "}";
            else
                returnString += std::string(1, auxFile::scrapLetter(scrapNumber)) + "}";
            if(!auxFileWasParsed())
                lastFragmentPage++;
            else
                lastFragmentPage = currentFragmentPage;
            fragmentDefinitionNumber++;
        }
        if(lastFirstFragment != nullptr){
            returnString += "}";
        }
        returnString += "$\\,\\rangle$ {\\footnotesize ";
        returnString += referenceString;
        returnString += "}\n\\end{list}}"; 
        return returnString;
    }
@| texUtf8 @}
\subsubsection{setGlobal}
\indexClassMethod{indexFragmentNames}{setGlobal}
@d \classImplementation{indexFragmentNames}
@{@%
    void nuweb::indexFragmentNames::setGlobal(void){
        m_global = true;
    }
@| setGlobal @}
