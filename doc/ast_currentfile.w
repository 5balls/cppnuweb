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

\section{Class currentFile}
\subsection{Interface}
\indexClass{currentFile}
@d \classDeclaration{currentFile}
@{@%
class currentFile : public emptyDocumentPart {
private:
    
public:
    currentFile();
    virtual std::string texUtf8(void) const override;
    virtual std::string fileUtf8(filePosition& l_filePosition) const override;
    virtual std::string quotedFileUtf8(filePosition& l_filePosition) const override;
};
@| currentFile @}

\subsubsection{currentFile}
\indexClassMethod{currentFile}{currentFile}
@d \classImplementation{currentFile}
@{@%
     nuweb::currentFile::currentFile(void) : emptyDocumentPart(){
        
    }
@| currentFile @}

\subsubsection{texUtf8}
\indexClassMethod{currentFile}{texUtf8}
@d \classImplementation{currentFile}
@{@%
    std::string nuweb::currentFile::texUtf8(void) const{
        return "@@\\hbox{\\sffamily\\slshape file name}\\verb@@";
    }
@| texUtf8 @}

\subsubsection{fileUtf8}
\indexClassMethod{currentFile}{fileUtf8}
@d \classImplementation{currentFile}
@{@%
    std::string nuweb::currentFile::fileUtf8(filePosition& l_filePosition) const{
        std::string returnString = l_filePosition.m_filename;
        return indexableText::progressFilePosition(l_filePosition, returnString);
    }
@| fileUtf8 @}

\subsubsection{quotedFileUtf8}
\indexClassMethod{currentFile}{quotedFileUtf8}
@d \classImplementation{currentFile}
@{@%
    std::string nuweb::currentFile::quotedFileUtf8(filePosition& l_filePosition) const{
        return indexableText::progressFilePosition(l_filePosition,"@@f");
    }
@| quotedFileUtf8 @}
