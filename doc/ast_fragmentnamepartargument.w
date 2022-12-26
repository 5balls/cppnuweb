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

\section{Class fragmentNamePartArgument}
\subsection{Interface}
@d \classDeclaration{fragmentNamePartArgument}
@{@%
class fragmentNamePartArgument : public fragmentNamePartDefinition, public documentPart {
private:
    int m_argumentNumber = 0;
protected:
    virtual bool isEqualWith(const fragmentNamePartDefinition& toCompareWith) const override;
public:
    fragmentNamePartArgument(filePosition* l_filePosition);
    fragmentNamePartArgument(documentPart&& l_documentPart);
    fragmentNamePartArgument(unsigned int argumentNumber);
    virtual std::string utf8(filePosition& l_filePosition) const override;
    virtual std::string texUtf8(void) const override;
};
@| fragmentNamePartArgument @}
\subsubsection{fragmentNamePartArgument}
\indexClassMethod{fragmentNamePartArgument}{fragmentNamePartArgument}
@d \classImplementation{fragmentNamePartArgument}
@{@%
     nuweb::fragmentNamePartArgument::fragmentNamePartArgument(filePosition* l_filePosition) : fragmentNamePartDefinition(), documentPart(l_filePosition){
        
    }
@| fragmentNamePartArgument @}
\subsubsection{fragmentNamePartArgument}
\indexClassMethod{fragmentNamePartArgument}{fragmentNamePartArgument}
@d \classImplementation{fragmentNamePartArgument}
@{@%
     nuweb::fragmentNamePartArgument::fragmentNamePartArgument(documentPart&& l_documentPart) : fragmentNamePartDefinition(), documentPart(std::move(l_documentPart)) {
        
    }
@| fragmentNamePartArgument @}
\subsubsection{fragmentNamePartArgument}
\indexClassMethod{fragmentNamePartArgument}{fragmentNamePartArgument}
@d \classImplementation{fragmentNamePartArgument}
@{@%
     nuweb::fragmentNamePartArgument::fragmentNamePartArgument(unsigned int argumentNumber) : fragmentNamePartDefinition(), documentPart(emptyDocumentPart()), m_argumentNumber(argumentNumber) {
        
    }
@| fragmentNamePartArgument @}
\subsubsection{utf8}
\indexClassMethod{fragmentNamePartArgument}{utf8}
@d \classImplementation{fragmentNamePartArgument}
@{@%
    std::string nuweb::fragmentNamePartArgument::utf8(filePosition& l_filePosition) const{
        if(m_argumentNumber > 0)
            return "";
        else
            return documentPart::utf8(l_filePosition);
    }
@| utf8 @}
\subsubsection{texUtf8}
\indexClassMethod{fragmentNamePartArgument}{texUtf8}
@d \classImplementation{fragmentNamePartArgument}
@{@%
    std::string nuweb::fragmentNamePartArgument::texUtf8(void) const{
        if(m_argumentNumber>0){
            if(m_argumentNumber < 10)
                m_texFilePositionColumnCorrection = -1;
            else if(m_argumentNumber < 100)
                m_texFilePositionColumnCorrection = -2;
            else
                throw std::runtime_error("More than 99 arguments not supported!");
            return "{\\tt @@}";
        }
        else
            return "";
    }
@| texUtf8 @}
\subsubsection{isEqualWith}
\indexClassMethod{fragmentNamePartArgument}{isEqualWith}
@d \classImplementation{fragmentNamePartArgument}
@{@%
    bool nuweb::fragmentNamePartArgument::isEqualWith(const fragmentNamePartDefinition& toCompareWith) const{
        // Type does not need to be equal for different types of arguments
        // so we only check for castibility to fragmentNamePartArgument.
        // typeid would return the more specific type
        if(dynamic_cast<const fragmentNamePartArgument*>(&toCompareWith))
            return true;
        else
            return false;
        // We are done here, we don't need to look for base class equality
    }
@| isEqualWith @}
