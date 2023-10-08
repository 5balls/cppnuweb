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

\section{Class versionString}
\subsection{Interface}
\indexClass{versionString}
@d \classDeclaration{versionString}
@{@%
class versionString : public documentPart {
private:
    
public:
    versionString(filePosition* l_filePosition);
    virtual std::string texUtf8(void) const override;
    virtual std::string fileUtf8(filePosition& l_filePosition) const override;
};
@| versionString @}

\subsubsection{versionString}
\indexClassMethod{versionString}{versionString}
@d \classImplementation{versionString}
@{@%
     nuweb::versionString::versionString(filePosition* l_filePosition) : documentPart(l_filePosition){
        
    }
@| versionString @}

\subsubsection{texUtf8}
\indexClassMethod{versionString}{texUtf8}
@d \classImplementation{versionString}
@{@%
    std::string nuweb::versionString::texUtf8(void) const{
        return m_versionString; 
    }
@| texUtf8 @}

\subsubsection{fileUtf8}
\indexClassMethod{versionString}{fileUtf8}
@d \classImplementation{versionString}
@{@%
    std::string nuweb::versionString::fileUtf8(filePosition& l_filePosition) const{
        return indexableText::progressFilePosition(l_filePosition, m_versionString);
    }
@| fileUtf8 @}
