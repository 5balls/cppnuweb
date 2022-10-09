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

\chapter{Abstract Syntax Tree Classes}
We define some classes for our Abstract Syntax Tree. This correspond mostly to the non terminal expressions in the Bison grammar and are used there to build up the tree.

\section{General definitions}
\indexHeader{DEFINITIONS}
@O ../src/definitions.h -d
@{
@<Start of @'DEFINITIONS@' header@>

#include <vector>
#include <iostream>

namespace nuweb {
@}

@O ../src/definitions.h -d
@{
@<C++ structure definitions in namespace nuweb@>
@<C++ enum class definitions in namespace nuweb@>
@}

\indexStructure{filePositionWithInt}
@O ../src/definitions.h -d
@{
    struct filePositionWithInt : public filePosition {
        filePositionWithInt(const std::string& filename, 
                unsigned int line, unsigned int column,
                unsigned int line_end, unsigned int column_end,
                int value):
            filePosition(filename,line,column,line_end,column_end),
            mn_value(value){
            };
        int mn_value;
    };
@}

\indexStructure{filePositionWithString}
@O ../src/definitions.h -d
@{
    struct filePositionWithString : public filePosition {
        filePositionWithString(const filePosition& l_filePosition,
                std::string value):
            filePosition(l_filePosition),
            m_value(value){};
        filePositionWithString(const std::string& filename, 
                unsigned int line, unsigned int column,
                unsigned int line_end, unsigned int column_end,
                const std::string& value):
            filePosition(filename,line,column,line_end,column_end),
            m_value(value){
                //std::cout << "filePositionWithString::filePositionWithString::value" << value << "";
                //std::cout << "filePositionWithString::filePositionWithString::m_value" << value << "";
            };
        std::string m_value;
    };
}
@<End of header@>
@}

\section{Class document}
\subsection{Interface}
\indexHeader{DOCUMENT}
@O ../src/document.h -d
@{@%
@<Start of @'DOCUMENT@' header@>

#include "documentPart.h"

namespace nuweb {
@<\classDeclaration{document}@>
}
@<End of header@>
@}

\subsection{Implementation}
See @{@<\classDeclaration{document}@>@}.

\section{Class documentPart}
\subsection{Interface}
\indexHeader{DOCUMENT\_PART}@O ../src/documentPart.h -d
@{@%
@<Start of @'DOCUMENT_PART@' header@>
#include <vector>
#include <algorithm>
#include "definitions.h"
#include "file.h"
#include "auxfile.h"

namespace nuweb {
@<\classDeclaration{documentPart}@>
@<\classDeclaration{escapeCharacterDocumentPart}@>
@<\classDeclaration{scrap}@>
@<\classDeclaration{scrapVerbatim}@>
@<\classDeclaration{fragmentDefinition}@>
@<\classDeclaration{fragmentNamePartDefinition}@>
@<\classDeclaration{fragmentReference}@>
@<\classDeclaration{outputFile}@>
@<\classDeclaration{emptyDocumentPart}@>
}
@<End of header@>
@}

\subsection{Implementation}
@d C++ files without main in path @'path@'
@{@1documentPart.cpp
@}

@o ../src/documentPart.cpp -d
@{
#include "documentPart.h"

@<\staticDefinitions{documentPart}@>
@<\staticDefinitions{escapeCharacterDocumentPart}@>
@<\staticDefinitions{fragmentDefinition}@>
@<\staticDefinitions{fragmentNamePartDefinition}@>

@<\classImplementation{documentPart}@>
@<\classImplementation{fragmentDefinition}@>
@<\classImplementation{fragmentReference}@>
@<\classImplementation{fragmentNamePartDefinition}@>
@<\classImplementation{outputFile}@>
@}

\subsubsection{utf8}
\indexClassMethod{documentPart}{utf8}
@d \classImplementation{documentPart}
@{@%
std::string nuweb::documentPart::utf8(void) const{
    if(empty()){
        // Line numbers in lex start by one, internally we start at 0, so we
        // have to substract one here:
        if(!m_filePosition) throw std::runtime_error("Internal error: documentPart without file pointer!");
        std::string filename = m_filePosition->m_filename;
        if(filename.empty())
            return "";
        else {
            file* l_file = file::byName(filename);
            //std::cout << "File access in \"" << m_filePosition->m_filename << "\": " << m_filePosition->m_line-1 << "," << m_filePosition->m_column << " " << m_filePosition->m_line_end-1 << "," << m_filePosition->m_column_end << "\n";
            return l_file->utf8({{m_filePosition->m_line-1,m_filePosition->m_column},
                    {m_filePosition->m_line_end-1,m_filePosition->m_column_end}});
        }
    }
    else{
        std::string returnString;
        for(auto documentPart: *this)
            returnString += documentPart->utf8();
        return returnString;
    }
}
@| utf8 @}

\subsubsection{texUtf8}
\indexClassMethod{documentPart}{texUtf8}
@d \classImplementation{documentPart}
@{@%
std::string nuweb::documentPart::texUtf8() const{
    if(empty()){
        return utf8();
    }
    else{
        std::string returnString;
        for(auto& documentPart: *this)
            returnString += documentPart->texUtf8();
        return returnString;
    }
};
@| texUtf8 @}

\subsubsection{fileUtf8}
\indexClassMethod{documentPart}{fileUtf8}
@d \classImplementation{documentPart}
@{@%
std::string nuweb::documentPart::fileUtf8() const{
    if(empty()){
        return "";
    }
    else{
        std::string returnString;
        for(auto& documentPart: *this)
            returnString += documentPart->fileUtf8();
        return returnString;
    }
}
@}

\section{Class fragmentDefinition}
\subsection{Interface}
@d \classDeclaration{fragmentDefinition}
@{@%
class fragmentDefinition : public documentPart {
protected:
    static unsigned int m_scrapNumber;
    static std::map<unsigned int, fragmentDefinition*> fragmentDefinitions;
    static std::map<unsigned int, std::vector<unsigned int> > m_scrapsDefiningAFragment;
    documentPart* m_fragmentName; 
    unsigned int m_fragmentNameSize;
    documentPart* m_scrap;
    unsigned int m_currentScrapNumber;
    std::vector<unsigned int> m_referencesInScraps;
    bool m_pageBreak;
public:
    static fragmentDefinition* fragmentFromFragmentName(const documentPart* fragmentName);
    std::vector<unsigned int> scrapsFromFragment(void);
    static std::vector<unsigned int> scrapsFromFragmentName(const documentPart* fragmentName);
    fragmentDefinition(documentPart* l_fragmentName, documentPart* l_scrap, bool pageBreak = false); 
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
};
@| fragmentDefinition @}
\subsection{Implementation}
\subsubsection{fragmentDefinition}
@d \classImplementation{fragmentDefinition}
@{@%
    nuweb::fragmentDefinition::fragmentDefinition(documentPart* l_fragmentName, documentPart* l_scrap, bool pageBreak) : m_fragmentName(l_fragmentName), m_scrap(l_scrap), m_currentScrapNumber(++m_scrapNumber), m_fragmentNameSize(m_fragmentName->size()), m_pageBreak(pageBreak){
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
                if(l_fragmentDefinition->m_fragmentName->at(fragmentNamePart)->utf8().compare(fragmentName->at(fragmentNamePart)->utf8()) != 0){
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
        fragmentDefinition* firstFragment = fragmentFromFragmentName(m_fragmentName);
        if(!firstFragment)
            throw std::runtime_error("Internal error, could not get first scrap of fragment!");
        std::vector<unsigned int> referencesInScraps = firstFragment->referencesInScraps();
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
        fragmentDefinition* firstFragment = fragmentFromFragmentName(m_fragmentName);
        if(!firstFragment)
            throw std::runtime_error("Internal error, could not get first scrap of fragment!");
        unsigned int firstFragmentNumber = firstFragment->scrapNumber();
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
\subsubsection{referencesInScraps}
@d \classImplementation{fragmentDefinition}
@{@%
    std::vector<unsigned int> nuweb::fragmentDefinition::referencesInScraps(void) const{
        return m_referencesInScraps;
    }
@}

\section{Class fragmentReference}
\subsection{Interface}
@d \classDeclaration{fragmentReference}
@{@%
class fragmentReference : public documentPart {
private:
    fragmentDefinition* m_fragment;
    documentPart* m_unresolvedFragmentName;
    unsigned int m_scrapNumber;
public:
    fragmentReference(documentPart* fragmentName);
    virtual std::string utf8(void) const override;
    virtual std::string texUtf8(void) const override;
};
@}

\subsection{Implementation}
\subsubsection{fragmentReference}
@d \classImplementation{fragmentReference}
@{@%
    nuweb::fragmentReference::fragmentReference(documentPart* fragmentName) : m_unresolvedFragmentName(nullptr){
        m_fragment = fragmentDefinition::fragmentFromFragmentName(fragmentName);
        if(!m_fragment) m_unresolvedFragmentName = fragmentName;
        m_scrapNumber = fragmentDefinition::totalNumberOfScraps() + 1;
        if(m_fragment) m_fragment->addReferenceScrapNumber(m_scrapNumber);
    }
@}
\subsubsection{texUtf8}
@d \classImplementation{fragmentReference}
@{@%
    std::string nuweb::fragmentReference::texUtf8(void) const{
        fragmentDefinition* fragment = m_fragment;
        if(!fragment) fragment = fragmentDefinition::fragmentFromFragmentName(m_unresolvedFragmentName);
        if(!fragment) throw std::runtime_error("Could not resolve fragment \"" + m_unresolvedFragmentName->texUtf8() + "\" in file " + m_unresolvedFragmentName->filePositionString());
        fragment->addReferenceScrapNumber(m_scrapNumber);
        std::string returnString = "@@\\hbox{$\\langle\\,${\\itshape ";
        returnString += fragment->name();
        returnString += "}\\nobreak\\ {\\footnotesize \\NWlink{nuweb";
        std::string scrapNumber = "?";
        if(documentPart::auxFileWasParsed())
            scrapNumber = auxFile::scrapId(fragment->scrapNumber());
        else
            std::cout << "No aux file yet, need to run Latex again!\n";
        returnString += scrapNumber + "}{" + scrapNumber + "}";
        if(fragment->scrapsFromFragment().size() > 1)
            returnString += ", \\ldots\\ ";
        if(listingsPackageEnabled())
            returnString += "}$\\,\\rangle$}\\lstinline@@";
        else
            returnString += "}$\\,\\rangle$}\\verb@@";
        return returnString;
    }
@}
\subsubsection{utf8}
@d \classImplementation{fragmentReference}
@{@%
    std::string nuweb::fragmentReference::utf8(void) const{
        fragmentDefinition* fragment = m_fragment;
        if(!fragment) fragment = fragmentDefinition::fragmentFromFragmentName(m_unresolvedFragmentName);
        if(!fragment) throw std::runtime_error("Could not resolve fragment \"" + m_unresolvedFragmentName->texUtf8() + "\" in file " + m_unresolvedFragmentName->filePositionString());
        fragment->addReferenceScrapNumber(m_scrapNumber);
        return fragment->utf8();
    }
@}

\section{Class fragmentNamePartDefinition}
\subsection{Interface}
@d \classDeclaration{fragmentNamePartDefinition}
@{@%
class fragmentNamePartDefinition : public documentPart {
private:
    bool m_isArgument = false;
    static std::vector<fragmentNamePartDefinition*> m_allFragmentPartDefinitions;
public:
    fragmentNamePartDefinition(filePosition* l_filePosition, bool isArgument);
    fragmentNamePartDefinition(documentPart&& l_documentPart, bool isArgument);
    bool operator==(const fragmentNamePartDefinition& toCompareWith);
    virtual std::string texUtf8() const override;
};
@| fragmentNamePartDefinition @}
\subsection{Implementation}
\subsubsection{fragmentNamePartDefinition}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
    nuweb::fragmentNamePartDefinition::fragmentNamePartDefinition(filePosition* l_filePosition, bool isArgument) : documentPart(l_filePosition), m_isArgument(isArgument) {
        m_allFragmentPartDefinitions.push_back(this);
    }
@}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
    nuweb::fragmentNamePartDefinition::fragmentNamePartDefinition(documentPart&& l_documentPart, bool isArgument) : documentPart(std::move(l_documentPart)), m_isArgument(isArgument) {
        m_allFragmentPartDefinitions.push_back(this);
    }
@}
\subsubsection{operator==}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
    bool nuweb::fragmentNamePartDefinition::operator==(const fragmentNamePartDefinition& toCompareWith){
        if(m_isArgument && toCompareWith.m_isArgument)
            return m_isArgument == toCompareWith.m_isArgument;
        else
            if(m_isArgument != toCompareWith.m_isArgument)
                return false;
            else
                return utf8() == toCompareWith.utf8();
    }
@}
\subsubsection{texUtf8}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
    std::string nuweb::fragmentNamePartDefinition::texUtf8() const{
        if(m_isArgument)
            return "\\hbox{\\slshape\\sffamily " + utf8() + "\\/}";
        else
            return utf8();
    }
@| texUtf8 @}

\section{Class outputFile}
\subsection{Interface}
@d \classDeclaration{outputFile}
@{
class outputFile: public fragmentDefinition {
private:
    std::string m_filename;
    static std::map<std::string, std::string> m_fileContents;
public:
    outputFile(documentPart* l_fileName, documentPart* l_scrap, bool pageBreak = false);
    virtual std::string headerTexUtf8(void) const override;
    virtual std::string referencesTexUtf8(void) const override;
    virtual std::string fileUtf8(void) const override;
};
@| outputFile @}

\subsection{Implementation}
\subsubsection{outputFile}
@d \classImplementation{outputFile}
@{@%
    nuweb::outputFile::outputFile(documentPart* l_fileName, documentPart* l_scrap, bool pageBreak) : fragmentDefinition(l_fileName, l_scrap, pageBreak) {
        m_filename = l_fileName->utf8();
    }
@| outputFile @}

\subsubsection{headerTexUtf8}
@d \classImplementation{outputFile}
@{@%
    std::string nuweb::outputFile::headerTexUtf8(void) const{
        std::string scrapId = "?";
        if(documentPart::auxFileWasParsed())
            scrapId = nuweb::auxFile::scrapId(m_currentScrapNumber);
        std::string returnString = "\\NWtarget{nuweb";
        returnString += scrapId;
        returnString += "}{} \\verb@@\"";
        returnString += m_fragmentName->texUtf8();
        returnString += "\"@@\\nobreak\\ {\\footnotesize {";
        returnString += scrapId;
        returnString += "}}$\\equiv$\n";
        return returnString;
    }
@| headerTexUtf8 @}

\subsubsection{referencesTexUtf8}
@d \classImplementation{outputFile}
@{@%
    std::string nuweb::outputFile::referencesTexUtf8(void) const{
        return "";
    }
@| referencesTexUtf8 @}

\subsubsection{fileUtf8}
@d \classImplementation{outputFile}
@{@%
    std::string nuweb::outputFile::fileUtf8(void) const{
        return m_scrap->fileUtf8();
    }
@| fileUtf8 @}
