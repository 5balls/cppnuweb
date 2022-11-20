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

\section{Class documentPart}
\subsection{Interface}
\indexHeader{DOCUMENT\_PART}@O ../src/documentPart.h -d
@{@%
@<Start of @'DOCUMENT_PART@' header@>
#include <vector>
#include <algorithm>
#include <fstream>
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
@<\classDeclaration{fragmentArgument}@>
@<\classDeclaration{userIdentifiers}@>
@<\classDeclaration{indexFragmentNames}@>
}
@<End of header@>
@}


\indexClass{documentPart}\indexClassBaseOf{documentPart}{outputFile}\indexClassBaseOf{documentPart}{emptyDocumentPart}
@d \classDeclaration{documentPart}
@{@%
class documentPart: public std::vector<documentPart*> {
private:
    filePosition* m_filePosition = nullptr;
    static bool auxFileParsed;
    static bool m_listingsPackageEnabled;
    static bool m_hyperlinksEnabled;
protected:
    std::string thisString(void) const;
    static int m_texFilePositionColumnCorrection;
    static unsigned int m_fileIndentation;
public:
    documentPart(const documentPart&) = delete;
    documentPart(void);
    documentPart(documentPart&& l_documentPart);
    documentPart(documentPart* l_documentPart);
    documentPart(filePosition* l_filePosition);
    std::string filePositionString() const;
    virtual std::string utf8() const;
    virtual std::string utf8LineNumber(void) const;
    virtual std::string texUtf8() const;
    virtual std::string fileUtf8() const;
    virtual std::string fileUtf8LineNumber(void) const;
    virtual void resolveReferences(void);
    virtual void resolveReferences2(void);
    void setAuxFileParsed(bool wasParsed);
    static bool auxFileWasParsed(void);
    void setListingsPackageEnabled(bool listingsPackageEnabled);
    static bool listingsPackageEnabled(void);
    void setHyperlinksEnabled(bool hyperlinksEnabled);
    static bool hyperlinksEnabled(void);
    unsigned int leadingSpaces(void) const;
    bool setFilePosition(filePosition* l_filePosition);
};
@| documentPart utf8 texUtf8 @}

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
@<\staticDefinitions{outputFile}@>
@<\staticDefinitions{userIdentifier}@>

@<\classImplementation{documentPart}@>
@<\classImplementation{fragmentDefinition}@>
@<\classImplementation{fragmentReference}@>
@<\classImplementation{fragmentNamePartDefinition}@>
@<\classImplementation{outputFile}@>
@<\classImplementation{scrapVerbatim}@>
@<\classImplementation{scrap}@>
@<\classImplementation{fragmentArgument}@>
@<\classImplementation{userIdentifiers}@>
@<\classImplementation{indexFragmentNames}@>
@}

\subsubsection{documentPart}
\indexClassMethod{documentPart}{documentPart}
@d \classImplementation{documentPart}
@{@%
    nuweb::documentPart::documentPart(void) : std::vector<documentPart*>({}) {
    }
    nuweb::documentPart::documentPart(documentPart&& l_documentPart) : m_filePosition(l_documentPart.m_filePosition), std::vector<documentPart*>(std::move(l_documentPart)) {
    }
    nuweb::documentPart::documentPart(documentPart* l_documentPart) : documentPart(std::move(*l_documentPart)){
    }
    nuweb::documentPart::documentPart(filePosition* l_filePosition) : m_filePosition(l_filePosition){
    }
@| documentPart @}

\subsubsection{filePositionString}
\indexClassMethod{documentPart}{filePositionString}
@d \classImplementation{documentPart}
@{@%
    std::string nuweb::documentPart::filePositionString(void) const{
        if(empty())
            return "[" + m_filePosition->m_filename + ":" + std::to_string(m_filePosition->m_line) + "," + std::to_string(m_filePosition->m_column) + "|" + std::to_string(m_filePosition->m_line_end) + "," + std::to_string(m_filePosition->m_column_end) + "]";
        else{
            return "[" + this->front()->m_filePosition->m_filename + ":" + std::to_string(this->front()->m_filePosition->m_line) + "," + std::to_string(this->front()->m_filePosition->m_column) + "|" + std::to_string(this->back()->m_filePosition->m_line_end) + "," + std::to_string(this->back()->m_filePosition->m_column_end) + "]";
        }
    }
@| filePositionString @}

\subsubsection{setAuxFileParsed}
\indexClassMethod{documentPart}{setAuxFileParsed}
@d \classImplementation{documentPart}
@{@%
    void nuweb::documentPart::setAuxFileParsed(bool wasParsed){
        auxFileParsed = wasParsed;
    }
@| setAuxFileParsed @}

\subsubsection{auxFileWasParsed}
\indexClassMethod{documentPart}{auxFileWasParsed}
@d \classImplementation{documentPart}
@{@%
    bool nuweb::documentPart::auxFileWasParsed(void){
        return auxFileParsed;
    }
@| auxFileWasParsed @}

\subsubsection{setListingsPackageEnabled}
\indexClassMethod{documentPart}{setListingsPackageEnabled}
@d \classImplementation{documentPart}
@{@%
    void nuweb::documentPart::setListingsPackageEnabled(bool listingsPackageEnabled){
        m_listingsPackageEnabled = listingsPackageEnabled;
    }
@| setListingsPackageEnabled @}

\subsubsection{listingsPackageEnabled}
\indexClassMethod{documentPart}{listingsPackageEnabled}
@d \classImplementation{documentPart}
@{@%
    bool nuweb::documentPart::listingsPackageEnabled(void){
        return m_listingsPackageEnabled;
    }
@| listingsPackageEnabled @}

\subsubsection{setHyperlinksEnabled}
\indexClassMethod{documentPart}{setHyperlinksEnabled}
@d \classImplementation{documentPart}
@{@%
    void nuweb::documentPart::setHyperlinksEnabled(bool hyperlinksEnabled){
        m_hyperlinksEnabled = hyperlinksEnabled;
    }
@| setHyperlinksEnabled @}

\subsubsection{hyperlinksEnabled}
\indexClassMethod{documentPart}{hyperlinksEnabled}
@d \classImplementation{documentPart}
@{@%
    bool nuweb::documentPart::hyperlinksEnabled(void){
        return m_hyperlinksEnabled;
    }
@| hyperlinksEnabled @}

\subsubsection{utf8}
\indexClassMethod{documentPart}{utf8}
@d \classImplementation{documentPart}
@{@%
std::string nuweb::documentPart::utf8(void) const{
    static int lastIndentedLine=-1;
    static int currentLine=0;
    if(empty()){
        // Line numbers in lex start by one, internally we start at 0, so we
        // have to substract one here:
        if(!m_filePosition){
            throw std::runtime_error("Internal error: documentPart without file pointer!" + std::string(typeid(*this).name()) + " " + thisString() + "\n");
        }
        std::string filename = m_filePosition->m_filename;
        if(filename.empty())
            return "";
        else {
            file* l_file = file::byName(filename);
            //std::cout << "File access in \"" << m_filePosition->m_filename << "\": " << m_filePosition->m_line-1 << "," << m_filePosition->m_column << " " << m_filePosition->m_line_end-1 << "," << m_filePosition->m_column_end << "\n";
            if(m_texFilePositionColumnCorrection != 0)
            {
                int columnCorrection = m_texFilePositionColumnCorrection;
                m_texFilePositionColumnCorrection = 0;
                if(lastIndentedLine != currentLine){
                    std::string returnString = l_file->utf8({{m_filePosition->m_line-1,m_filePosition->m_column+columnCorrection},
                            {m_filePosition->m_line_end-1,m_filePosition->m_column_end}},
                            m_fileIndentation);
                    currentLine += std::count(returnString.begin(), returnString.end(), '\n');
                    lastIndentedLine = currentLine;
                    return returnString;
                }
                else{
                    std::string returnString = l_file->utf8({{m_filePosition->m_line-1,m_filePosition->m_column+columnCorrection},
                            {m_filePosition->m_line_end-1,m_filePosition->m_column_end}});
                    currentLine += std::count(returnString.begin(), returnString.end(), '\n');
                    return returnString;
                }
            }
            if(lastIndentedLine != currentLine){
                std::string returnString = l_file->utf8({{m_filePosition->m_line-1,m_filePosition->m_column},
                        {m_filePosition->m_line_end-1,m_filePosition->m_column_end}},
                        m_fileIndentation);
                currentLine += std::count(returnString.begin(), returnString.end(), '\n');
                lastIndentedLine = currentLine;
                return returnString;
            }
            else{
                std::string returnString = l_file->utf8({{m_filePosition->m_line-1,m_filePosition->m_column},
                        {m_filePosition->m_line_end-1,m_filePosition->m_column_end}});
                currentLine += std::count(returnString.begin(), returnString.end(), '\n');
                return returnString;
            }
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

\subsubsection{utf8LineNumber}
\indexClassMethod{documentPart}{utf8LineNumber}
@d \classImplementation{documentPart}
@{@%
    std::string nuweb::documentPart::utf8LineNumber(void) const{
        if(empty()){
            if(!m_filePosition)
                throw std::runtime_error("Internal error: documentPart without file pointer!" + std::string(typeid(*this).name()) + " " + thisString() + "\n");
            std::string filename = m_filePosition->m_filename;
            if(filename.empty())
                return "";
            std::string returnString = "\n#line ";
            returnString += std::to_string(m_filePosition->m_line) + " ";
            returnString += "\"" + filename + "\"\n";
            returnString += utf8();
            return returnString;    
        }
        else{
            std::string returnString;
            for(auto documentPart: *this)
                returnString += documentPart->utf8LineNumber();
            return returnString;
        }
    }
@| utf8LineNumber @}
\subsubsection{texUtf8}
\indexClassMethod{documentPart}{texUtf8}
@d \classImplementation{documentPart}
@{@%
std::string nuweb::documentPart::texUtf8() const{
    if(empty()){
        return utf8();
        /*std::string returnValue = utf8();
        bool documentPartIsOnlyWhitespace = std::all_of(returnValue.begin(),returnValue.end(),::isspace);
        if(documentPartIsOnlyWhitespace)
            return "\n";
        else
            return returnValue;*/
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
        return utf8();
    }
    else{
        std::string returnString;
        for(auto& documentPart: *this)
            returnString += documentPart->fileUtf8();
        return returnString;
    }
}
@}
\subsubsection{fileUtf8LineNumber}
\indexClassMethod{documentPart}{fileUtf8LineNumber}
@d \classImplementation{documentPart}
@{@%
    std::string nuweb::documentPart::fileUtf8LineNumber(void) const{
        if(empty()){
            return utf8LineNumber();
        }
        else{
            std::string returnString;
            for(auto& documentPart: *this)
                returnString += documentPart->fileUtf8LineNumber();
            return returnString;
        }
    }
@| fileUtf8LineNumber @}

\subsubsection{resolveReferences}
\indexClassMethod{documentPart}{resolveReferences}
@d \classImplementation{documentPart}
@{@%
    void nuweb::documentPart::resolveReferences(void){
        // To be implemented by derived classes that need it
        if(!empty())
            for(auto& documentPart: *this)
                documentPart->resolveReferences();
    }
@| resolveReferences @}

\subsubsection{resolveReferences2}
\indexClassMethod{documentPart}{resolveReferences2}
@d \classImplementation{documentPart}
@{@%
    void nuweb::documentPart::resolveReferences2(void){
        // To be implemented by derived classes that need it
        if(!empty())
            for(auto& documentPart: *this)
                documentPart->resolveReferences2();
    }
@| resolveReferences2 @}


\subsubsection{thisString}
\indexClassMethod{documentPart}{thisString}
@d \classImplementation{documentPart}
@{@%
    std::string nuweb::documentPart::thisString(void) const{
        std::stringstream thisStream;
        thisStream << this;
        return thisStream.str();
    }
@| thisString @}
\subsubsection{leadingSpaces}
\indexClassMethod{documentPart}{leadingSpaces}
@d \classImplementation{documentPart}
@{@%
    unsigned int nuweb::documentPart::leadingSpaces(void) const{
        if(!m_filePosition)
            return 0;
        std::string filename = m_filePosition->m_filename;
        if(filename.empty())
            return 0;
        else {
            file* l_file = file::byName(filename);
            if(m_filePosition->m_column>0) 
               if(l_file->utf8({{m_filePosition->m_line-1,0},{m_filePosition->m_line-1,m_filePosition->m_column-1}}).find_first_not_of(' ') != std::string::npos)
                   return 0;
               else
                   return m_filePosition->m_column;
            else
                return 0;
        }
    }
@| leadingSpaces @}
\subsubsection{setFilePosition}
\indexClassMethod{documentPart}{setFilePosition}
@d \classImplementation{documentPart}
@{@%
    bool nuweb::documentPart::setFilePosition(filePosition* l_filePosition){
       if(!m_filePosition){
           m_filePosition = l_filePosition;
           return true;
       } 
       else
           return false;
    }
@| setFilePosition @}
