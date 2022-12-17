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

\section{Class outputFile}
\subsection{Interface}
@d \classDeclaration{outputFile}
@{
class outputFile: public fragmentDefinition {
private:
    std::string m_filename;
    static std::vector<fragmentDefinition*> m_outputFiles;
    std::vector<enum outputFileFlags> m_flags;
    static std::vector<std::vector<enum outputFileFlags> > m_allFlags;
    static std::vector<enum outputFileFlags> m_currentFlags;
public:
    outputFile(documentPart* l_fileName, documentPart* l_scrap, bool pageBreak = false, std::vector<enum outputFileFlags> flags={});
    virtual std::string headerTexUtf8(void) const override;
    virtual std::string referencesTexUtf8(void) const override;
    virtual std::string fileUtf8(filePosition& l_filePosition) const override;
    virtual std::string definedByTexUtf8(void) const override;
    static void writeFiles(void);
    static std::vector<enum outputFileFlags> currentFlags(void);
};
@| outputFile @}

@d \staticDefinitions{outputFile}
@{@%
    std::vector<nuweb::fragmentDefinition*> nuweb::outputFile::m_outputFiles = {};
    std::vector<enum nuweb::outputFileFlags> nuweb::outputFile::m_currentFlags = {};
    std::vector<std::vector<enum nuweb::outputFileFlags> > nuweb::outputFile::m_allFlags = {};
@| m_outputFiles @}

\subsection{Implementation}
\subsubsection{outputFile}
\indexClassMethod{outputFile}{outputFile}
@d \classImplementation{outputFile}
@{@%
    nuweb::outputFile::outputFile(documentPart* l_fileName, documentPart* l_scrap, bool pageBreak, std::vector<enum outputFileFlags> flags) : fragmentDefinition(l_fileName, l_scrap, pageBreak), m_flags(flags) {
        filePosition ll_filePosition("",1,documentPart::m_fileIndentation+1,1,1);
        m_filename = l_fileName->utf8(ll_filePosition);
        fragmentDefinition* firstFragment = fragmentFromFragmentName(m_definitionSectionLevel, m_fragmentName);
        if(!firstFragment)
            throw std::runtime_error("Internal error, could not get first scrap of outputfile!");
        if(find(m_outputFiles.begin(),m_outputFiles.end(),firstFragment)==m_outputFiles.end()){
            m_outputFiles.push_back(firstFragment);
            m_allFlags.push_back(flags);
        }

    }
@| outputFile @}
\subsubsection{headerTexUtf8}
\indexClassMethod{outputFile}{headerTexUtf8}
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
\indexClassMethod{outputFile}{referencesTexUtf8}
@d \classImplementation{outputFile}
@{@%
    std::string nuweb::outputFile::referencesTexUtf8(void) const{
        return "";
    }
@| referencesTexUtf8 @}
\subsubsection{fileUtf8}
\indexClassMethod{outputFile}{fileUtf8}
@d \classImplementation{outputFile}
@{@%
    std::string nuweb::outputFile::fileUtf8(filePosition& l_filePosition) const{
        std::string returnString;
        documentPart::setCommentStyle(m_flags);
        if(std::find(m_flags.begin(), m_flags.end(), outputFileFlags::FORCE_LINE_NUMBERS) != m_flags.end())
            returnString = m_scrap->fileUtf8LineNumber(l_filePosition);
        else
            returnString = m_scrap->fileUtf8(l_filePosition);
        documentPart::setCommentStyle({});
        return returnString;
    }
@| fileUtf8 @}
\subsubsection{writeFiles}
\indexClassMethod{outputFile}{writeFiles}
@d \classImplementation{outputFile}
@{@%
    void nuweb::outputFile::writeFiles(void){
        unsigned int currentOutputFileIndex = 0;
        for(const auto& outputFile: m_outputFiles){
            m_currentFlags = m_allFlags.at(currentOutputFileIndex);
            std::string outputFileName = outputFile->name();
            filePosition l_filePosition(outputFileName, 0, 0, 0, 0);
            std::ofstream outputFileStream;
            std::string outputFileContent;
            std::vector<unsigned int> outputScraps = outputFile->scrapsFromFragment();
            for(const auto& outputScrap: outputScraps){
                fragmentDefinition* outputFragment = fragmentDefinitions[outputScrap];
                if(!outputFragment)
                    throw std::runtime_error("Internal error, could not get fragment when trying to write output files!");
                outputFileContent += outputFragment->fileUtf8(l_filePosition);
            }

            //std::string outputFileName = outputFile->name().substr(0,outputFile->name().find_last_of('.')) + ".txt";
            outputFileStream.open(outputFileName);
            //outputFileStream.open(outputFile->name());
            outputFileStream << outputFileContent;
            outputFileStream.close();
            currentOutputFileIndex++;
        }
    }
@| writeFiles @}
\subsubsection{currentFlags}
\indexClassMethod{outputFile}{currentFlags}
@d \classImplementation{outputFile}
@{@%
    std::vector<enum nuweb::outputFileFlags> nuweb::outputFile::currentFlags(void){
       return m_currentFlags; 
    }
@| currentFlags @}
\subsubsection{definedByTexUtf8}
\indexClassMethod{outputFile}{definedByTexUtf8}
@d \classImplementation{outputFile}
@{@%
    std::string nuweb::outputFile::definedByTexUtf8(void) const{
        unsigned int firstFragmentNumber = m_firstFragment->scrapNumber();
        if(m_scrapsDefiningAFragment[firstFragmentNumber].size()>1){
            std::string returnString = "\\item \\NWtxtFileDefBy\\ ";
            unsigned int lastPage = 0;
            for(const auto & scrapDefiningFragment: m_scrapsDefiningAFragment[firstFragmentNumber]){
                std::string scrapId = "?"; 
                unsigned int currentPage = 1;
                if(auxFileWasParsed()){
                    scrapId = auxFile::scrapId(scrapDefiningFragment);
                    currentPage = auxFile::scrapPage(scrapDefiningFragment);
                }
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
                if(auxFileWasParsed())
                    returnString += std::string(1, auxFile::scrapLetter(scrapDefiningFragment)) + "}";
                else
                    returnString += ", ?}";
                lastPage = currentPage;
            }
            returnString += ".\n";
            return returnString;
        }
        else
            return "";

    }
@| definedByTexUtf8 @}
