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
public:
    outputFile(documentPart* l_fileName, documentPart* l_scrap, bool pageBreak = false, std::vector<enum outputFileFlags> flags={});
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
\indexClassMethod{fragmentDefinition}{outputFile}
@d \classImplementation{outputFile}
@{@%
    nuweb::outputFile::outputFile(documentPart* l_fileName, documentPart* l_scrap, bool pageBreak, std::vector<enum outputFileFlags> flags) : fragmentDefinition(l_fileName, l_scrap, pageBreak), m_flags(flags) {
        m_filename = l_fileName->utf8();
        fragmentDefinition* firstFragment = fragmentFromFragmentName(m_fragmentName);
        if(!firstFragment)
            throw std::runtime_error("Internal error, could not get first scrap of outputfile!");
        if(find(m_outputFiles.begin(),m_outputFiles.end(),firstFragment)==m_outputFiles.end())
            m_outputFiles.push_back(firstFragment);

    }
@| outputFile @}
\subsubsection{headerTexUtf8}
\indexClassMethod{fragmentDefinition}{headerTexUtf8}
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
\indexClassMethod{fragmentDefinition}{referencesTexUtf8}
@d \classImplementation{outputFile}
@{@%
    std::string nuweb::outputFile::referencesTexUtf8(void) const{
        return "";
    }
@| referencesTexUtf8 @}
\subsubsection{fileUtf8}
\indexClassMethod{fragmentDefinition}{fileUtf8}
@d \classImplementation{outputFile}
@{@%
    std::string nuweb::outputFile::fileUtf8(void) const{
        std::string returnString;
        documentPart::setCommentStyle(m_flags);
        if(std::find(m_flags.begin(), m_flags.end(), outputFileFlags::FORCE_LINE_NUMBERS) != m_flags.end())
            returnString = m_scrap->fileUtf8LineNumber();
        else
            returnString = m_scrap->fileUtf8();
        documentPart::setCommentStyle({});
        return returnString;
    }
@| fileUtf8 @}
\subsubsection{writeFiles}
\indexClassMethod{fragmentDefinition}{writeFiles}
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

            //std::string outputFileName = outputFile->name().substr(0,outputFile->name().find_last_of('.')) + ".txt";
            std::string outputFileName = outputFile->name();
            outputFileStream.open(outputFileName);
            //outputFileStream.open(outputFile->name());
            outputFileStream << outputFileContent;
            outputFileStream.close();
        }
    }
@| writeFiles @}
