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

\section{Class fragmentNamePartArgumentString}
\subsection{Interface}
@d \classDeclaration{fragmentNamePartArgumentString}
@{@%
class fragmentNamePartArgumentString : public fragmentNamePartArgument {
private:
    
public:
    fragmentNamePartArgumentString(filePosition* l_filePosition);
    fragmentNamePartArgumentString(documentPart&& l_documentPart);
    virtual std::string texUtf8(void) const override;
};
@| fragmentNamePartArgumentString @}
\subsubsection{fragmentNamePartArgumentString}
\indexClassMethod{fragmentNamePartArgumentString}{fragmentNamePartArgumentString}
@d \classImplementation{fragmentNamePartArgumentString}
@{@%
     nuweb::fragmentNamePartArgumentString::fragmentNamePartArgumentString(filePosition* l_filePosition) : fragmentNamePartArgument(l_filePosition) {
        
    }
@| fragmentNamePartArgumentString @}
\subsubsection{fragmentNamePartArgumentString}
\indexClassMethod{fragmentNamePartArgumentString}{fragmentNamePartArgumentString}
@d \classImplementation{fragmentNamePartArgumentString}
@{@%
     nuweb::fragmentNamePartArgumentString::fragmentNamePartArgumentString(documentPart&& l_documentPart) : fragmentNamePartArgument(std::move(l_documentPart)){
        
    }
@| fragmentNamePartArgumentString @}
\subsubsection{texUtf8}
\indexClassMethod{fragmentNamePartArgumentString}{texUtf8}
@d \classImplementation{fragmentNamePartArgumentString}
@{@%
    std::string nuweb::fragmentNamePartArgumentString::texUtf8(void) const{
        return "\\hbox{\\slshape\\sffamily " + utf8() + "\\/}";
    }
@| texUtf8 @}
