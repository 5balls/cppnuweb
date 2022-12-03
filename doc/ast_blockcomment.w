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

\section{Class blockComment}
\subsection{Interface}
@d \classDeclaration{blockComment}
@{@%
class blockComment : public documentPart {
private:
    static blockComment* m_lastBlockComment;    
public:
    blockComment(filePosition* l_filePosition);
    virtual std::string texUtf8(void) const override;
    static blockComment* lastBlockComment(void);
};
@| blockComment @}
\subsubsection{blockComment}
\indexClassMethod{blockComment}{blockComment}
@d \classImplementation{blockComment}
@{@%
     nuweb::blockComment::blockComment(filePosition* l_filePosition) : documentPart(l_filePosition){
        m_lastBlockComment = this;
    }
@| blockComment @}

@d \staticDefinitions{blockComment}
@{@%
    nuweb::blockComment* nuweb::blockComment::m_lastBlockComment = nullptr;
@}


\subsubsection{texUtf8}
\indexClassMethod{blockComment}{texUtf8}
@d \classImplementation{blockComment}
@{@%
    std::string nuweb::blockComment::texUtf8(void) const{
        std::string returnString;
        if(!m_insideBlock){
            returnString += "\\begin{flushleft} \\small";
            returnString += "\n\\begin{minipage}{\\linewidth}";
            m_insideBlock = true;
        }
        filePosition ll_filePosition("",1,documentPart::m_fileIndentation+1,1,1);
        returnString += utf8(ll_filePosition); 
        return returnString;
    }
@| texUtf8 @}
\subsubsection{lastBlockComment}
\indexClassMethod{blockComment}{lastBlockComment}
@d \classImplementation{blockComment}
@{@%
    nuweb::blockComment* nuweb::blockComment::lastBlockComment(void){
       return m_lastBlockComment; 
    }
@| lastBlockComment @}
