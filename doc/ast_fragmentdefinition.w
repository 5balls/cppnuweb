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
class fragmentReference;
class fragmentNamePartText;
class fragmentNamePartDefinition;

class fragmentDefinition : public documentPart {
private:
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
    std::vector<fragmentReference*> m_references;
    fragmentDefinition* m_firstFragment;
public:
    fragmentDefinition(documentPart* l_fragmentName, documentPart* l_scrap, bool pageBreak = false); 
    static fragmentDefinition* fragmentFromFragmentName(const documentPart* fragmentName);
    std::vector<unsigned int> scrapsFromFragment(void);
    static std::vector<unsigned int> scrapsFromFragmentName(const documentPart* fragmentName);
    static std::vector<documentPart*> fragmentDefinitionsNames(void);
    static std::vector<unsigned int> fragmentDefinitionsScrapNumbers(void);
    fragmentNamePartText* findLongFormNamePart(unsigned int argumentNumber);
    fragmentNamePartDefinition* findNamePart(unsigned int argumentNumber);
    void addReferenceScrapNumber(unsigned int scrapNumber);
    unsigned int scrapNumber(void);
    static unsigned int totalNumberOfScraps(void);
    std::string name(void) const;
    documentPart* getScrap(void);
    unsigned int fragmentNameSize(void) const;
    std::vector<unsigned int> referencesInScraps(void) const;
    virtual std::string headerTexUtf8(void) const;
    virtual std::string referencesTexUtf8(void) const;
    virtual std::string usesTexUtf8(void) const;
    std::string definesTexUtf8(void) const;
    virtual std::string definedByTexUtf8(void) const;
    virtual std::string texUtf8(void) const override;
    virtual std::string utf8(filePosition& l_filePosition) const override;
    virtual std::string fileUtf8(filePosition& l_filePosition) const override;
    std::string fileUtf8(filePosition& l_filePosition, documentPart* fragmentName) const;
    virtual void resolveReferences(void) override;
    virtual void resolveReferences2(void) override;
    std::string scrapFileUtf8(filePosition& l_filePosition) const;
    std::string scrapFileUtf8(filePosition& l_filePosition, documentPart* fragmentName) const;
    void addReference(fragmentReference*);
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
\indexClassMethod{fragmentDefinition}{fragmentDefinition}
@d \classImplementation{fragmentDefinition}
@{@%
    nuweb::fragmentDefinition::fragmentDefinition(documentPart* l_fragmentName, documentPart* l_scrap, bool pageBreak) : m_fragmentName(l_fragmentName), m_currentScrapNumber(++m_scrapNumber), m_fragmentNameSize(m_fragmentName->size()), m_pageBreak(pageBreak){
        unsigned int fragmentNamePartNumber = 0;
        for(auto& fragmentNamePart: *m_fragmentName){
            fragmentNamePartDefinition* fragmentArgument = dynamic_cast<fragmentNamePartDefinition*>(fragmentNamePart);
            if(fragmentArgument)
            {
                fragmentArgument->setParent(this);
                fragmentArgument->setNamePartNumber(fragmentNamePartNumber);
            }
            fragmentNamePartNumber++;
        }
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
\indexClassMethod{fragmentDefinition}{fragmentFromFragmentName}
@d \classImplementation{fragmentDefinition}
@{@%
    nuweb::fragmentDefinition* nuweb::fragmentDefinition::fragmentFromFragmentName(const documentPart* fragmentName){
        unsigned int fragmentNameSize = fragmentName->size();
        if(fragmentNameSize == 0){
            for(const auto& [currentScrapNumber, l_fragmentDefinition]: fragmentDefinitions){
                if(l_fragmentDefinition->m_fragmentNameSize != 0) continue;
                filePosition ll_filePosition("",1,documentPart::m_fileIndentation+1,1,1);
                if(l_fragmentDefinition->m_fragmentName->utf8(ll_filePosition).compare(fragmentName->utf8(ll_filePosition)) == 0)
                    return l_fragmentDefinition;
            }
            return nullptr;
        } 
        for(const auto& [currentScrapNumber, l_fragmentDefinition]: fragmentDefinitions){
            //if(l_fragmentDefinition->m_fragmentNameSize != fragmentNameSize) continue;
            bool fragmentNamesIdentical = true;
            for(unsigned int fragmentNamePart = 0; fragmentNamePart < fragmentNameSize; fragmentNamePart++){
                if(fragmentNamePart >= l_fragmentDefinition->m_fragmentNameSize){
                    fragmentNamesIdentical = false;
                    break;
                }
                fragmentNamePartDefinition* compareFrom = dynamic_cast<fragmentNamePartDefinition*>(l_fragmentDefinition->m_fragmentName->at(fragmentNamePart));
                if(!compareFrom)
                    throw std::runtime_error("Internal error, could not compare fragment argument!");
                fragmentNamePartDefinition* compareTo = dynamic_cast<fragmentNamePartDefinition*>(fragmentName->at(fragmentNamePart));
                if(!compareTo)
                    throw std::runtime_error("Internal error, could not compare fragment argument!");
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
\indexClassMethod{fragmentDefinition}{scrapNumber}
@d \classImplementation{fragmentDefinition}
@{@%
    unsigned int nuweb::fragmentDefinition::scrapNumber(void) {
        return m_currentScrapNumber;
    }
@}
\subsubsection{scrapsFromFragmentName}
\indexClassMethod{fragmentDefinition}{scrapsFromFragmentName}
@d \classImplementation{fragmentDefinition}
@{@%
    std::vector<unsigned int> nuweb::fragmentDefinition::scrapsFromFragmentName(const documentPart* fragmentName){
        unsigned int fragmentNameSize = fragmentName->size();
        if(fragmentNameSize == 0){
            for(const auto& [currentScrapNumber, l_fragmentDefinition]: fragmentDefinitions){
                if(l_fragmentDefinition->m_fragmentNameSize != 0) continue;
                filePosition ll_filePosition("",1,documentPart::m_fileIndentation+1,1,1);
                if(l_fragmentDefinition->m_fragmentName->utf8(ll_filePosition).compare(fragmentName->utf8(ll_filePosition)) == 0){
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
                filePosition ll_filePosition("",1,documentPart::m_fileIndentation+1,1,1);
                if(l_fragmentDefinition->m_fragmentName->at(fragmentNamePart)->utf8(ll_filePosition).compare(fragmentName->at(fragmentNamePart)->utf8(ll_filePosition)) != 0){
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
\indexClassMethod{fragmentDefinition}{scrapsFromFragment}
@d \classImplementation{fragmentDefinition}
@{@%
std::vector<unsigned int> nuweb::fragmentDefinition::scrapsFromFragment(void){
    return scrapsFromFragmentName(m_fragmentName);
}
@}
\subsubsection{addReferenceScrapNumber}
\indexClassMethod{fragmentDefinition}{addReferenceScrapNumber}
@d \classImplementation{fragmentDefinition}
@{@%
    void nuweb::fragmentDefinition::addReferenceScrapNumber(unsigned int scrapNumber){
        if(std::find(m_referencesInScraps.begin(), m_referencesInScraps.end(), scrapNumber) == m_referencesInScraps.end()) 
            m_referencesInScraps.push_back(scrapNumber);
        std::sort(m_referencesInScraps.begin(), m_referencesInScraps.end());
    }
@}
\subsubsection{totalNumberOfScraps}
\indexClassMethod{fragmentDefinition}{totalNumberOfScraps}
@d \classImplementation{fragmentDefinition}
@{@%
    unsigned int nuweb::fragmentDefinition::totalNumberOfScraps(void){
        return m_scrapNumber;
    }
@}
\subsubsection{name}
\indexClassMethod{fragmentDefinition}{name}
@d \classImplementation{fragmentDefinition}
@{@%
    std::string nuweb::fragmentDefinition::name(void) const {
        if(m_fragmentName)
            return m_fragmentName->texUtf8();
        else
            return "";
    }
@}
\subsubsection{getScrap}
\indexClassMethod{fragmentDefinition}{getScrap}
@d \classImplementation{fragmentDefinition}
@{@%
    nuweb::documentPart* nuweb::fragmentDefinition::getScrap(void){
        return m_scrap;
    }
@| getScrap @}
\subsubsection{fragmentNameSize}
\indexClassMethod{fragmentDefinition}{fragmentNameSize}
@d \classImplementation{fragmentDefinition}
@{@%
    unsigned int nuweb::fragmentDefinition::fragmentNameSize(void) const{
        return m_fragmentNameSize;
    }
@| fragmentNameSize @}
\subsubsection{headerTexUtf8}
\indexClassMethod{fragmentDefinition}{headerTexUtf8}
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
\indexClassMethod{fragmentDefinition}{referencesTexUtf8}
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
\indexClassMethod{fragmentDefinition}{definedByTexUtf8}
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
\indexClassMethod{fragmentDefinition}{texUtf8}
@d \classImplementation{fragmentDefinition}
@{@%
    std::string nuweb::fragmentDefinition::texUtf8(void) const{
        std::string returnString;
        if(!m_insideBlock)
            returnString += "\\begin{flushleft} \\small";
        if(!m_pageBreak){
            if(!m_insideBlock){
                returnString += "\n\\begin{minipage}{\\linewidth}";
                m_insideBlock = true;
            }
            else
                returnString += "\\par\\vspace{\\baselineskip}\n";
        }
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
        returnString += definesTexUtf8();
        returnString += usesTexUtf8();
        returnString += "\n\\item{}\n";
        returnString += "\\end{list}\n";
        if(!m_pageBreak && m_insideBlock)
            returnString += "\\end{minipage}";
        returnString += "\\vspace{4ex}\n\\end{flushleft}\n";
        m_insideBlock = false;
        return returnString;
    }
@}
\subsubsection{utf8}
\indexClassMethod{fragmentDefinition}{utf8}
@d \classImplementation{fragmentDefinition}
@{@%
    std::string nuweb::fragmentDefinition::utf8(filePosition& l_filePosition) const{
        if(!m_scrap)
            throw ("Internal error, scrap not set in fragment definition");
        return m_scrap->utf8(l_filePosition);
    }
@| utf8 @}
\subsubsection{referencesInScraps}
\indexClassMethod{fragmentDefinition}{referencesInScraps}
@d \classImplementation{fragmentDefinition}
@{@%
    std::vector<unsigned int> nuweb::fragmentDefinition::referencesInScraps(void) const{
        return m_referencesInScraps;
    }
@}
\subsubsection{fileUtf8}
\indexClassMethod{fragmentDefinition}{fileUtf8}
@d \classImplementation{fragmentDefinition}
@{@%
    std::string nuweb::fragmentDefinition::fileUtf8(filePosition& l_filePosition) const{
        std::vector<unsigned int> scraps = scrapsFromFragmentName(m_fragmentName);
        std::string returnString;
        for(const auto& scrap: scraps){
            returnString += fragmentDefinitions[scrap]->scrapFileUtf8(l_filePosition);
        }
        return returnString;
    }
@| fileUtf8 @}
\subsubsection{fileUtf8}
\indexClassMethod{fragmentDefinition}{fileUtf8}
@d \classImplementation{fragmentDefinition}
@{@%
    std::string nuweb::fragmentDefinition::fileUtf8(filePosition& l_filePosition, documentPart* fragmentName) const{
        unsigned int cacheIndentation = documentPart::m_fileIndentation;
        documentPart::m_fileIndentation = 0;
        std::vector<unsigned int> scraps = scrapsFromFragmentName(m_fragmentName);
        documentPart::m_fileIndentation = cacheIndentation;
        std::string returnString;
        for(const auto& scrap: scraps){
            returnString += fragmentDefinitions[scrap]->scrapFileUtf8(l_filePosition, fragmentName);
        }
        return returnString;
    }
@| fileUtf8 @}
\subsubsection{scrapFileUtf8}
\indexClassMethod{fragmentDefinition}{scrapFileUtf8}
@d \classImplementation{fragmentDefinition}
@{@%
    std::string nuweb::fragmentDefinition::scrapFileUtf8(filePosition& l_filePosition) const{
        return m_scrap->fileUtf8(l_filePosition);
    }
@| scrapFileUtf8 @}
\subsubsection{scrapFileUtf8}
\indexClassMethod{fragmentDefinition}{scrapFileUtf8}
@d \classImplementation{fragmentDefinition}
@{@%
    std::string nuweb::fragmentDefinition::scrapFileUtf8(filePosition& l_filePosition, documentPart* fragmentName) const{
        m_scrap->resolveFragmentArguments(fragmentName);
        return m_scrap->fileUtf8(l_filePosition);
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
        m_scrap->setUserIdentifiersScrapNumber(m_currentScrapNumber);
        m_scrap->setCrossReferencesScrapNumber(m_currentScrapNumber);
        if(m_scrap->empty())
            m_scrap->resolveReferences();
        else
            for(auto& scrapPart: *m_scrap)
                scrapPart->resolveReferences();
    }
@| resolveReferences @}
\subsubsection{resolveReferences2}
\indexClassMethod{fragmentDefinition}{resolveReferences2}
@d \classImplementation{fragmentDefinition}
@{@%
    void nuweb::fragmentDefinition::resolveReferences2(){
        if(m_scrap->empty())
            m_scrap->resolveReferences2();
        else
            for(auto& scrapPart: *m_scrap)
                scrapPart->resolveReferences2();

        std::vector<std::pair<std::string, std::vector<unsigned int> > > usedIdentifiersInFragment;
        filePosition ll_filePosition("",1,documentPart::m_fileIndentation+1,1,1);
        usedIdentifiersInFragment = userIdentifiers::uses(m_scrap->utf8(ll_filePosition));
        for(auto& usedIdentifier: usedIdentifiersInFragment)
            userIdentifiers::setScrapUsingIdentifier(usedIdentifier.first, m_currentScrapNumber);
        for(const auto& definitionFragmentNamePart: *m_fragmentName)
            definitionFragmentNamePart->resolveReferences2();
    }
@| resolveReferences2 @}
\subsubsection{usesTexUtf8}
\indexClassMethod{fragmentDefinition}{usesTexUtf8}
@d \classImplementation{fragmentDefinition}
@{@%
    std::string nuweb::fragmentDefinition::usesTexUtf8(void) const{
        std::vector<std::pair<std::string, std::vector<unsigned int> > > usedIdentifiersInFragment;
        filePosition ll_filePosition("",1,documentPart::m_fileIndentation+1,1,1);
        usedIdentifiersInFragment = userIdentifiers::uses(m_scrap->utf8(ll_filePosition));
        if(usedIdentifiersInFragment.empty()) return "";
        std::string returnString;
        returnString = "\\item \\NWtxtIdentsUsed\\nobreak\\ ";
        bool b_foundUsed = false;
        for(auto& usedIdentifier: usedIdentifiersInFragment){
            // We only "use" the identifiers we don't define ourself:
            if(std::find(usedIdentifier.second.begin(), usedIdentifier.second.end(), m_currentScrapNumber) != usedIdentifier.second.end()) continue;
            b_foundUsed = true;
            returnString += " \\verb@@" + usedIdentifier.first + "@@\\nobreak\\ ";
            unsigned int lastPage = 0;
            for(auto scrapNumber: usedIdentifier.second){
                std::string scrapId = auxFile::scrapId(scrapNumber);
                unsigned int currentPage = auxFile::scrapPage(scrapNumber);
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
                returnString += std::string(1, auxFile::scrapLetter(scrapNumber)) + "}";
                lastPage = currentPage;
            }
            returnString += ",";
        }
        if(!b_foundUsed) return "";
        returnString.pop_back();
        returnString += ".";
        return returnString;
    }
@| usesTexUtf8 @}
\subsubsection{definesTexUtf8}
\indexClassMethod{fragmentDefinition}{definesTexUtf8}
@d \classImplementation{fragmentDefinition}
@{@%
    std::string nuweb::fragmentDefinition::definesTexUtf8(void) const{
        std::vector<std::pair<std::string, std::vector<unsigned int> > > definedIdentifiersInFragment;
        definedIdentifiersInFragment = userIdentifiers::defines(m_currentScrapNumber);
        if(definedIdentifiersInFragment.empty()) return "";
        std::string returnString;
        returnString = "\\item \\NWtxtIdentsDefed\\nobreak\\ ";
        for(auto& definedIdentifier: definedIdentifiersInFragment){
            returnString += " \\verb@@" + definedIdentifier.first + "@@\\nobreak\\ ";
            unsigned int lastPage = 0;
            if(definedIdentifier.second.empty())
                returnString += "\\NWtxtIdentsNotUsed";
            else
                for(auto scrapNumber: definedIdentifier.second){
                    std::string scrapId = auxFile::scrapId(scrapNumber);
                    unsigned int currentPage = auxFile::scrapPage(scrapNumber);
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
                    returnString += std::string(1, auxFile::scrapLetter(scrapNumber)) + "}";
                    lastPage = currentPage;
                }
            returnString += ",";
        }
        returnString.pop_back();
        returnString += ".";
        return returnString;
       
    }
@| definesTexUtf8 @}
\subsubsection{fragmentDefinitionsNames}
\indexClassMethod{fragmentDefinition}{fragmentDefinitionsNames}
@d \classImplementation{fragmentDefinition}
@{@%
    std::vector<nuweb::documentPart*> nuweb::fragmentDefinition::fragmentDefinitionsNames(void){
        std::vector<documentPart*> fragmentNames;
        for(auto& fragmentDefinition: fragmentDefinitions)
            fragmentNames.push_back(fragmentDefinition.second->m_fragmentName);
        return fragmentNames;
    }
@| fragmentDefinitionsNames @}
\subsubsection{fragmentDefinitionsScrapNumbers}
\indexClassMethod{fragmentDefinition}{fragmentDefinitionsScrapNumbers}
@d \classImplementation{fragmentDefinition}
@{@%
    std::vector<unsigned int> nuweb::fragmentDefinition::fragmentDefinitionsScrapNumbers(void){
        std::vector<unsigned int> scrapNumbers;
        for(auto& fragmentDefinition: fragmentDefinitions)
            scrapNumbers.push_back(fragmentDefinition.second->m_scrapNumber);
        return scrapNumbers;
    }
@| fragmentDefinitionsScrapNumbers @}
\subsubsection{addReference}
\indexClassMethod{fragmentDefinition}{addReference}
@d \classImplementation{fragmentDefinition}
@{@%
    void nuweb::fragmentDefinition::addReference(fragmentReference* reference){
        if(std::find(m_references.begin(), m_references.end(), reference) == m_references.end())
            m_references.push_back(reference);
        else{
            std::ostringstream address;
            address << (void const *)reference;
            throw std::runtime_error("Internal error, trying to add the same reference \"" + address.str() + "\" twice!");
        }
    }
@| addReference @}
\subsubsection{findLongFormNamePart}
\indexClassMethod{fragmentDefinition}{findLongFormNamePart}
@d \classImplementation{fragmentDefinition}
@{@%
    nuweb::fragmentNamePartText* nuweb::fragmentDefinition::findLongFormNamePart(unsigned int namePartNumber){
       if(m_fragmentNameSize>namePartNumber){
           fragmentNamePartText* possibleLongForm = dynamic_cast<fragmentNamePartText*>(m_fragmentName->at(namePartNumber));
           if(possibleLongForm)
               if(!possibleLongForm->isShortened())
                   return possibleLongForm;
       }
       for(const auto& reference: m_references){
           documentPart* referenceName = reference->getFragmentName();
           if(referenceName->size() <= namePartNumber)
               continue;
           fragmentNamePartText* possibleLongForm = dynamic_cast<fragmentNamePartText*>(referenceName->at(namePartNumber));
           if(possibleLongForm)
               if(!possibleLongForm->isShortened())
                   return possibleLongForm;
       }
       return nullptr;
    }
@| findLongFormNamePart @}
\subsubsection{findNamePart}
\indexClassMethod{fragmentDefinition}{findNamePart}
@d \classImplementation{fragmentDefinition}
@{@%
    nuweb::fragmentNamePartDefinition* nuweb::fragmentDefinition::findNamePart(unsigned int namePartNumber){
        fragmentNamePartText* possibleLongFormNamePart = findLongFormNamePart(namePartNumber);
        if(possibleLongFormNamePart)
            return possibleLongFormNamePart;
        if(m_fragmentNameSize>namePartNumber)
            return dynamic_cast<fragmentNamePartDefinition*>(m_fragmentName->at(namePartNumber));
        return nullptr;
    }
@| findNamePart @}
