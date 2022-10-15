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
public:
    outputFile(documentPart* l_fileName, documentPart* l_scrap, bool pageBreak = false);
    virtual std::string headerTexUtf8(void) const override;
    virtual std::string referencesTexUtf8(void) const override;
    virtual std::string fileUtf8(void) const override;
    static void writeFiles(void);
};
@| outputFile @}

@d \staticDefinitions{outputFile}
@{@%
    std::vector<nuweb::fragmentDefinition*> nuweb::outputFile::m_outputFiles = {};
@| m_outputFiles @}

\subsection{Implementation}
\subsubsection{outputFile}
@d \classImplementation{outputFile}
@{@%
    nuweb::outputFile::outputFile(documentPart* l_fileName, documentPart* l_scrap, bool pageBreak) : fragmentDefinition(l_fileName, l_scrap, pageBreak) {
        m_filename = l_fileName->utf8();
        fragmentDefinition* firstFragment = fragmentFromFragmentName(m_fragmentName);
        if(!firstFragment)
            throw std::runtime_error("Internal error, could not get first scrap of outputfile!");
        if(find(m_outputFiles.begin(),m_outputFiles.end(),firstFragment)==m_outputFiles.end())
            m_outputFiles.push_back(firstFragment);

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
\subsubsection{writeFiles}
@d \classImplementation{outputFile}
@{@%
    void nuweb::outputFile::writeFiles(void){
        for(const auto& outputFile: m_outputFiles){
            std::ofstream outputFileStream;
            std::string outputFileContent;
            std::vector<unsigned int> outputScraps = outputFile->scrapsFromFragment();
            for(const auto& outputScrap: outputScraps){
                fragmentDefinition* outputFragment = fragmentDefinitions[outputScrap];
                if(!outputFragment)
                    throw std::runtime_error("Internal error, could not get fragment when trying to write output files!");
                outputFileContent += outputFragment->fileUtf8();
            }

            std::string outputFileName = outputFile->name().substr(0,outputFile->name().find_last_of('.')) + "_dbg.txt";
            outputFileStream.open(outputFileName);
            //outputFileStream.open(outputFile->name());
            outputFileStream << outputFileContent;
            outputFileStream.close();
        }
    }
@| writeFiles @}
