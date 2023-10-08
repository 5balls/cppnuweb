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

\section{Class fragmentQuoted}
\subsection{Interface}
\indexClass{fragmentQuoted}
@d \classDeclaration{fragmentQuoted}
@{@%
class fragmentQuoted : public fragmentDefinition {
private:
    
public:
    fragmentQuoted(documentPart* l_fragmentName, documentPart* l_scrap, bool pageBreak = false);
    //virtual std::string texUtf8(void) const override;
    virtual std::string scrapFileUtf8(filePosition& l_filePosition) const override;
    virtual std::string scrapFileUtf8(filePosition& l_filePosition, const std::vector<std::string>& fragmentArgumentsExpanded, const std::vector<std::string>& fragmentArgumentsUnexpanded = {}) const override;
};
@| fragmentQuoted @}

\subsubsection{fragmentQuoted}
\indexClassMethod{fragmentQuoted}{fragmentQuoted}
@d \classImplementation{fragmentQuoted}
@{@%
     nuweb::fragmentQuoted::fragmentQuoted(documentPart* l_fragmentName, documentPart* l_scrap, bool pageBreak) : fragmentDefinition(l_fragmentName, l_scrap, pageBreak){
        
    }
@| fragmentQuoted @}

\subsubsection{scrapFileUtf8}
\indexClassMethod{fragmentQuoted}{scrapFileUtf8}
@d \classImplementation{fragmentQuoted}
@{@%
    std::string nuweb::fragmentQuoted::scrapFileUtf8(filePosition& l_filePosition) const{
        return m_scrap->quotedFileUtf8(l_filePosition);
    }
@| scrapFileUtf8 @}

\subsubsection{scrapFileUtf8}
\indexClassMethod{fragmentQuoted}{scrapFileUtf8}
@d \classImplementation{fragmentQuoted}
@{@%
    std::string nuweb::fragmentQuoted::scrapFileUtf8(filePosition& l_filePosition, const std::vector<std::string>& fragmentArgumentsExpanded, const std::vector<std::string>& fragmentArgumentsUnexpanded) const{
        m_scrap->resolveFragmentArguments(fragmentArgumentsExpanded, fragmentArgumentsUnexpanded);
        return m_scrap->quotedFileUtf8(l_filePosition);
        
    }
@| scrapFileUtf8 @}
