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

\section{Class fragmentDefinition}
\subsection{Interface}
@d \classDeclaration{fragmentDefinition}
@{@%
class fragmentDefinition : public documentPart {
private:
    fragmentDefinition* m_firstFragment;
protected:
    static unsigned int m_scrapNumber;
    static std::map<unsigned int, fragmentDefinition*> fragmentDefinitions;
    static std::map<unsigned int, std::vector<unsigned int> > m_scrapsDefiningAFragment;
    documentPart* m_fragmentName; 
    unsigned int m_fragmentNameSize;
    scrap* m_scrap;
    unsigned int m_currentScrapNumber;
    std::vector<unsigned int> m_referencesInScraps;
    bool m_pageBreak;
public:
    fragmentDefinition(documentPart* l_fragmentName, documentPart* l_scrap, bool pageBreak = false); 
    static fragmentDefinition* fragmentFromFragmentName(const documentPart* fragmentName);
    std::vector<unsigned int> scrapsFromFragment(void);
    static std::vector<unsigned int> scrapsFromFragmentName(const documentPart* fragmentName);
    void addReferenceScrapNumber(unsigned int scrapNumber);
    unsigned int scrapNumber(void);
    static unsigned int totalNumberOfScraps(void);
    std::string name(void) const;
    documentPart* scrap(void);
    std::vector<unsigned int> referencesInScraps(void) const;
    virtual std::string headerTexUtf8(void) const;
    virtual std::string referencesTexUtf8(void) const;
    std::string definedByTexUtf8(void) const;
    virtual std::string texUtf8(void) const override;
    virtual std::string utf8(void) const override;
    virtual std::string fileUtf8(void) const override;
    virtual void resolveReferences(void) override;
    std::string scrapFileUtf8(void) const;
};
@| fragmentDefinition @}

@d \staticDefinitions{fragmentDefinition}
@{@%
unsigned int nuweb::fragmentDefinition::m_scrapNumber = 0;
std::map<unsigned int, nuweb::fragmentDefinition*> nuweb::fragmentDefinition::fragmentDefinitions = {};
std::map<unsigned int, std::vector<unsigned int> > nuweb::fragmentDefinition::m_scrapsDefiningAFragment = {};
@}

\subsection{Implementation}
\subsubsection{fragmentDefinition}
@d \classImplementation{fragmentDefinition}
@{@%
    nuweb::fragmentDefinition::fragmentDefinition(documentPart* l_fragmentName, documentPart* l_scrap, bool pageBreak) : m_fragmentName(l_fragmentName), m_currentScrapNumber(++m_scrapNumber), m_fragmentNameSize(m_fragmentName->size()), m_pageBreak(pageBreak){
        m_scrap = dynamic_cast<class scrap*>(l_scrap);
        if(!m_scrap)
            throw std::runtime_error("Internal program error, documentPart passed fot fragmentDefinition is not a scrap as expected!");
        fragmentDefinitions[m_currentScrapNumber] = this;
        if(scrapsFromFragmentName(l_fragmentName).size()==0)
            throw std::runtime_error("Internal program error, could not maintain internal scrap list!");
        fragmentDefinition* firstFragment = fragmentFromFragmentName(l_fragmentName);
        if(firstFragment){
            unsigned int firstFragmentScrapNumber = firstFragment->scrapNumber();
            if(std::find(m_scrapsDefiningAFragment[firstFragmentScrapNumber].begin(),m_scrapsDefiningAFragment[firstFragmentScrapNumber].end(),m_currentScrapNumber) == m_scrapsDefiningAFragment[firstFragmentScrapNumber].end())
                m_scrapsDefiningAFragment[firstFragmentScrapNumber].push_back(m_currentScrapNumber);
        }
        else
            throw std::runtime_error("Internal program error, could not add scrap to scrap list!");
    }
@}
\subsubsection{fragmentFromFragmentName}
@d \classImplementation{fragmentDefinition}
@{@%
    nuweb::fragmentDefinition* nuweb::fragmentDefinition::fragmentFromFragmentName(const documentPart* fragmentName){
        unsigned int fragmentNameSize = fragmentName->size();
        if(fragmentNameSize == 0){
            for(const auto& [currentScrapNumber, l_fragmentDefinition]: fragmentDefinitions){
                if(l_fragmentDefinition->m_fragmentNameSize != 0) continue;
                if(l_fragmentDefinition->m_fragmentName->utf8().compare(fragmentName->utf8()) == 0)
                    return l_fragmentDefinition;
            }
            return nullptr;
        } 
        for(const auto& [currentScrapNumber, l_fragmentDefinition]: fragmentDefinitions){
            if(l_fragmentDefinition->m_fragmentNameSize != fragmentNameSize) continue;
            bool fragmentNamesIdentical = true;
            for(unsigned int fragmentNamePart = 0; fragmentNamePart < fragmentNameSize; fragmentNamePart++){
                fragmentNamePartDefinition* compareFrom = dynamic_cast<fragmentNamePartDefinition*>(l_fragmentDefinition->m_fragmentName->at(fragmentNamePart));
                if(!compareFrom)
                    throw ("Internal error, could not compare fragment argument!");
                fragmentNamePartDefinition* compareTo = dynamic_cast<fragmentNamePartDefinition*>(fragmentName->at(fragmentNamePart));
                if(!compareTo)
                    throw ("Internal error, could not compare fragment argument!");
                if(!(*compareFrom == *compareTo)){
                    fragmentNamesIdentical = false;
                    break;
                }
            }
            if(!fragmentNamesIdentical) continue;
            // If we reach here we found the corresponding fragment:
            return l_fragmentDefinition;
        }
        return nullptr;
    }
@}
\subsubsection{scrapNumber}
@d \classImplementation{fragmentDefinition}
@{@%
    unsigned int nuweb::fragmentDefinition::scrapNumber(void) {
        return m_currentScrapNumber;
    }
@}
\subsubsection{scrapsFromFragmentName}
@d \classImplementation{fragmentDefinition}
@{@%
    std::vector<unsigned int> nuweb::fragmentDefinition::scrapsFromFragmentName(const documentPart* fragmentName){
        unsigned int fragmentNameSize = fragmentName->size();
        if(fragmentNameSize == 0){
            for(const auto& [currentScrapNumber, l_fragmentDefinition]: fragmentDefinitions){
                if(l_fragmentDefinition->m_fragmentNameSize != 0) continue;
                if(l_fragmentDefinition->m_fragmentName->utf8().compare(fragmentName->utf8()) == 0){
                    // If we reach here we found the group
                    fragmentDefinition* newFragmentDefinition = fragmentFromFragmentName(fragmentName);
                    if(newFragmentDefinition){
                        unsigned int newScrapNumber = newFragmentDefinition->scrapNumber();
                        if(m_scrapsDefiningAFragment.count(currentScrapNumber) > 0){
                            std::vector<unsigned int> scrapsForThisFragment = m_scrapsDefiningAFragment[currentScrapNumber];
                            if(std::find(scrapsForThisFragment.begin(), scrapsForThisFragment.end(), newScrapNumber) != scrapsForThisFragment.end()){
                                return scrapsForThisFragment;
                            }
                            else{
                                m_scrapsDefiningAFragment[currentScrapNumber].push_back(newScrapNumber);
                                return m_scrapsDefiningAFragment[currentScrapNumber];
                            }
                        }
                        else{
                            m_scrapsDefiningAFragment[currentScrapNumber].push_back(newScrapNumber);
                            return m_scrapsDefiningAFragment[currentScrapNumber];
                        }
                    }
                    else
                        throw std::runtime_error("Internal error, can't find just added fragment definition reference!");

                }
            }
        }
        for(const auto& [currentScrapNumber, l_fragmentDefinition]: fragmentDefinitions){
            if(l_fragmentDefinition->m_fragmentNameSize != fragmentNameSize) continue;
            bool fragmentNamesIdentical = true;
            for(unsigned int fragmentNamePart = 0; fragmentNamePart < fragmentNameSize; fragmentNamePart++){
                if(l_fragmentDefinition->m_fragmentName->at(fragmentNamePart)->utf8().compare(fragmentName->at(fragmentNamePart)->utf8()) != 0){
                    fragmentNamesIdentical = false;
                    break;
                }
            }
            if(!fragmentNamesIdentical) continue;
            // If we reach here we found the group
            fragmentDefinition* newFragmentDefinition = fragmentFromFragmentName(fragmentName);
            if(newFragmentDefinition){
                unsigned int newScrapNumber = newFragmentDefinition->scrapNumber();
                if(m_scrapsDefiningAFragment.count(currentScrapNumber) > 0){
                    std::vector<unsigned int> scrapsForThisFragment = m_scrapsDefiningAFragment[currentScrapNumber];
                    if(std::find(scrapsForThisFragment.begin(), scrapsForThisFragment.end(), newScrapNumber) != scrapsForThisFragment.end()){
                        return scrapsForThisFragment;
                    }
                    else{
                        m_scrapsDefiningAFragment[currentScrapNumber].push_back(newScrapNumber);
                        return m_scrapsDefiningAFragment[currentScrapNumber];
                    }
                }
                else{
                    m_scrapsDefiningAFragment[currentScrapNumber].push_back(newScrapNumber);
                    return m_scrapsDefiningAFragment[currentScrapNumber];
                }
            }
            else
                throw std::runtime_error("Internal error, can't find just added fragment definition reference!");
        }
        return {};
    }
@}
\subsubsection{scrapsFromFragment}
@d \classImplementation{fragmentDefinition}
@{@%
std::vector<unsigned int> nuweb::fragmentDefinition::scrapsFromFragment(void){
    return scrapsFromFragmentName(m_fragmentName);
}
@}
\subsubsection{addReferenceScrapNumber}
@d \classImplementation{fragmentDefinition}
@{@%
    void nuweb::fragmentDefinition::addReferenceScrapNumber(unsigned int scrapNumber){
        if(std::find(m_referencesInScraps.begin(), m_referencesInScraps.end(), scrapNumber) == m_referencesInScraps.end()) 
            m_referencesInScraps.push_back(scrapNumber);
        std::sort(m_referencesInScraps.begin(), m_referencesInScraps.end());
    }
@}
\subsubsection{totalNumberOfScraps}
@d \classImplementation{fragmentDefinition}
@{@%
    unsigned int nuweb::fragmentDefinition::totalNumberOfScraps(void){
        return m_scrapNumber;
    }
@}
\subsubsection{name}
@d \classImplementation{fragmentDefinition}
@{@%
    std::string nuweb::fragmentDefinition::name(void) const {
        return m_fragmentName->texUtf8();
    }
@}

\subsubsection{scrap}
@d \classImplementation{fragmentDefinition}
@{@%
    nuweb::documentPart* nuweb::fragmentDefinition::scrap(void){
        return m_scrap;
    }
@}
\subsubsection{headerTexUtf8}
@d \classImplementation{fragmentDefinition}
@{@%
    std::string nuweb::fragmentDefinition::headerTexUtf8(void) const {
        std::string scrapId = "?";
        if(documentPart::auxFileWasParsed())
            scrapId = nuweb::auxFile::scrapId(m_currentScrapNumber);
        std::string returnString = "\\NWtarget{nuweb";
        returnString += scrapId;
        returnString += "}{} $\\langle\\,${\\itshape ";
        returnString += m_fragmentName->texUtf8();
        returnString += "}\\nobreak\\ {\\footnotesize {";
        returnString += scrapId;
        returnString += "}}$\\,\\rangle\\equiv$\n";
        return returnString;
    }
@}
\subsubsection{referencesTexUtf8}
@d \classImplementation{fragmentDefinition}
@{@%
    std::string nuweb::fragmentDefinition::referencesTexUtf8(void) const {
        std::string returnString;
        returnString += "\\item ";
        // We need to get the references from the first fragment which keeps those:
        std::vector<unsigned int> referencesInScraps = m_firstFragment->referencesInScraps();
        if(referencesInScraps.empty())
            returnString += "{\\NWtxtMacroNoRef}";
        else{
            returnString += "\\NWtxtMacroRefIn\\ ";
            unsigned int lastPage = 0;
            for(const auto & referenceInScrap: referencesInScraps){
                std::string scrapId = auxFile::scrapId(referenceInScrap);
                unsigned int currentPage = auxFile::scrapPage(referenceInScrap);
                returnString += "\\NWlink{nuweb" + scrapId + "}{";
                if(lastPage == 0){
                    returnString += scrapId + "}";
                    lastPage = currentPage;
                    continue;
                }
                if(currentPage != lastPage){
                    returnString += ", " + scrapId + "}";
                    lastPage = currentPage;
                    continue;
                }
                returnString += std::string(1, auxFile::scrapLetter(referenceInScrap)) + "}";
                lastPage = currentPage;
            }
        }
        returnString += ".\n";
        return returnString;
    }
@}
\subsubsection{definedByTexUtf8}
@d \classImplementation{fragmentDefinition}
@{@%
    std::string nuweb::fragmentDefinition::definedByTexUtf8(void) const{
        unsigned int firstFragmentNumber = m_firstFragment->scrapNumber();
        if(m_scrapsDefiningAFragment[firstFragmentNumber].size()>1){
            if(auxFileWasParsed()){
                std::string returnString = "\\item \\NWtxtMacroDefBy\\ ";
                unsigned int lastPage = 0;
                for(const auto & scrapDefiningFragment: m_scrapsDefiningAFragment[firstFragmentNumber]){
                    std::string scrapId = auxFile::scrapId(scrapDefiningFragment);
                    unsigned int currentPage = auxFile::scrapPage(scrapDefiningFragment);
                    returnString += "\\NWlink{nuweb" + scrapId + "}{";
                    if(lastPage == 0){
                        returnString += scrapId + "}";
                        lastPage = currentPage;
                        continue;
                    }
                    if(currentPage != lastPage){
                        returnString += ", " + scrapId + "}";
                        lastPage = currentPage;
                        continue;
                    }
                    returnString += std::string(1, auxFile::scrapLetter(scrapDefiningFragment)) + "}";
                    lastPage = currentPage;
                }
                returnString += ".\n";
                return returnString;
            }
            else
                return "";
        }
        else
            return "";
    }
@}
\subsubsection{texUtf8}
@d \classImplementation{fragmentDefinition}
@{@%
    std::string nuweb::fragmentDefinition::texUtf8(void) const{
        std::string returnString = "\\begin{flushleft} \\small";
        if(!m_pageBreak)
            returnString += "\n\\begin{minipage}{\\linewidth}";
        returnString += "\\label{scrap";
        returnString += std::to_string(m_currentScrapNumber) + "}\\raggedright\\small\n";
        returnString += headerTexUtf8();
        returnString += "\\vspace{-1ex}\n";
        returnString += "\\begin{list}{}{} \\item\n";
        scrapVerbatim* scrap = dynamic_cast<scrapVerbatim*>(m_scrap);
        if(!scrap)
            throw ("Internal problem convering scrap to scrap type in fragmentDefinition::texUtf8");
        returnString += m_scrap->texUtf8();
        returnString += "\\end{list}\n";
        returnString += "\\vspace{-1.5ex}\n";
        returnString += "\\footnotesize\n";
        returnString += "\\begin{list}{}{\\setlength{\\itemsep}{-\\parsep}\\setlength{\\itemindent}{-\\leftmargin}}\n";
        returnString += definedByTexUtf8();
        returnString += referencesTexUtf8();
        returnString += "\n\\item{}\n";
        returnString += "\\end{list}\n";
        if(!m_pageBreak)
            returnString += "\\end{minipage}";
        returnString += "\\vspace{4ex}\n\\end{flushleft}";
        returnString += "\n";
        return returnString;
    }
@}
\subsubsection{utf8}
@d \classImplementation{fragmentDefinition}
@{@%
    std::string nuweb::fragmentDefinition::utf8(void) const{
        return m_scrap->utf8();
    }
@| utf8 @}
\subsubsection{referencesInScraps}
@d \classImplementation{fragmentDefinition}
@{@%
    std::vector<unsigned int> nuweb::fragmentDefinition::referencesInScraps(void) const{
        return m_referencesInScraps;
    }
@}

\subsubsection{fileUtf8}
@d \classImplementation{fragmentDefinition}
@{@%
    std::string nuweb::fragmentDefinition::fileUtf8(void) const{
        std::vector<unsigned int> scraps = scrapsFromFragmentName(m_fragmentName);
        std::string returnString;
        for(const auto& scrap: scraps){
            returnString += fragmentDefinitions[scrap]->scrapFileUtf8();
        }
        return returnString;
    }
@| fileUtf8 @}

\subsubsection{scrapFileUtf8}
@d \classImplementation{fragmentDefinition}
@{@%
    std::string nuweb::fragmentDefinition::scrapFileUtf8(void) const{
        return m_scrap->fileUtf8();
    }
@| scrapFileUtf8 @}

\subsubsection{resolveReferences}
\indexClassMethod{fragmentDefinition}{resolveReferences}
@d \classImplementation{fragmentDefinition}
@{@%
    void nuweb::fragmentDefinition::resolveReferences(void){
        m_firstFragment = fragmentFromFragmentName(m_fragmentName);
        if(!m_firstFragment)
            throw std::runtime_error("Internal error, could resolve to first defining fragment!");
        m_scrap->resolveFragmentArguments(m_fragmentName);
        if(m_scrap->empty())
            m_scrap->resolveReferences();
        else
            for(auto& scrapPart: *m_scrap)
                scrapPart->resolveReferences();
    }
@| resolveReferences @}
