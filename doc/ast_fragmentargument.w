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

\section{Class fragmentArgument}
\subsection{Interface}
@d \classDeclaration{fragmentArgument}
@{@%
class fragmentArgument : public documentPart {
private:
    unsigned int m_number;
    fragmentNamePartDefinition* m_nameToExpandTo;
public:
    fragmentArgument(unsigned int number);
    void setNameToExpandTo(fragmentNamePartDefinition* nameToExpandTo);
    virtual std::string utf8(void) const override;
    virtual std::string texUtf8(void) const override;
    virtual std::string fileUtf8(void) const override;
    unsigned int number(void) const;
};
@| fragmentArgument @}

\subsection{Implementation}
\subsubsection{fragmentArgument}
\indexClassMethod{fragmentDefinition}{fragmentArgument}
@d \classImplementation{fragmentArgument}
@{@%
    nuweb::fragmentArgument::fragmentArgument(unsigned int number) : documentPart(), m_number(number), m_nameToExpandTo(nullptr){
        
    }
@| fragmentArgument @}

\subsubsection{texUtf8}
\indexClassMethod{fragmentDefinition}{texUtf8}
@d \classImplementation{fragmentArgument}
@{@%
    std::string nuweb::fragmentArgument::texUtf8(void) const{
        if(m_nameToExpandTo)
            if(listingsPackageEnabled())
                return "@@" + m_nameToExpandTo->texUtf8() + "\\lstinline@@";
            else
                return "@@" + m_nameToExpandTo->texUtf8() + "\\verb@@";
        else
            throw std::runtime_error("Could not resolve argument name at runtime!");
    }
@| texUtf8 @}

\subsubsection{setNameToExpandTo}
\indexClassMethod{fragmentDefinition}{setNameToExpandTo}
@d \classImplementation{fragmentArgument}
@{@%
    void nuweb::fragmentArgument::setNameToExpandTo(fragmentNamePartDefinition* nameToExpandTo){
        m_nameToExpandTo = nameToExpandTo;
    }
@| setNameToExpandTo @}
\subsubsection{number}
\indexClassMethod{fragmentDefinition}{number}
@d \classImplementation{fragmentArgument}
@{@%
    unsigned int nuweb::fragmentArgument::number(void) const{
        return m_number;
    }
@| number @}
\subsubsection{fileUtf8}
\indexClassMethod{fragmentArgument}{fileUtf8}
@d \classImplementation{fragmentArgument}
@{@%
    std::string nuweb::fragmentArgument::fileUtf8(void) const{
        return m_nameToExpandTo->utf8();
    }
@| fileUtf8 @}
\subsubsection{utf8}
\indexClassMethod{fragmentArgument}{utf8}
@d \classImplementation{fragmentArgument}
@{@%
    std::string nuweb::fragmentArgument::utf8(void) const{
        return "";     
    }
@| utf8 @}
