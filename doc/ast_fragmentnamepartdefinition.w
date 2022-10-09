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

\section{Class fragmentNamePartDefinition}
\subsection{Interface}
@d \classDeclaration{fragmentNamePartDefinition}
@{@%
class fragmentNamePartDefinition : public documentPart {
private:
    bool m_isArgument = false;
    static std::vector<fragmentNamePartDefinition*> m_allFragmentPartDefinitions;
public:
    fragmentNamePartDefinition(filePosition* l_filePosition, bool isArgument);
    fragmentNamePartDefinition(documentPart&& l_documentPart, bool isArgument);
    bool operator==(const fragmentNamePartDefinition& toCompareWith);
    virtual std::string texUtf8() const override;
};
@| fragmentNamePartDefinition @}
@d \staticDefinitions{fragmentNamePartDefinition}
@{@%
std::vector<nuweb::fragmentNamePartDefinition*> nuweb::fragmentNamePartDefinition::m_allFragmentPartDefinitions = {};
@| m_allFragmentPartDefinitions @}
\subsection{Implementation}
\subsubsection{fragmentNamePartDefinition}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
    nuweb::fragmentNamePartDefinition::fragmentNamePartDefinition(filePosition* l_filePosition, bool isArgument) : documentPart(l_filePosition), m_isArgument(isArgument) {
        m_allFragmentPartDefinitions.push_back(this);
    }
@}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
    nuweb::fragmentNamePartDefinition::fragmentNamePartDefinition(documentPart&& l_documentPart, bool isArgument) : documentPart(std::move(l_documentPart)), m_isArgument(isArgument) {
        m_allFragmentPartDefinitions.push_back(this);
    }
@}
\subsubsection{operator==}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
    bool nuweb::fragmentNamePartDefinition::operator==(const fragmentNamePartDefinition& toCompareWith){
        if(m_isArgument && toCompareWith.m_isArgument)
            return m_isArgument == toCompareWith.m_isArgument;
        else
            if(m_isArgument != toCompareWith.m_isArgument)
                return false;
            else
                return utf8() == toCompareWith.utf8();
    }
@}
\subsubsection{texUtf8}
@d \classImplementation{fragmentNamePartDefinition}
@{@%
    std::string nuweb::fragmentNamePartDefinition::texUtf8() const{
        if(m_isArgument)
            return "\\hbox{\\slshape\\sffamily " + utf8() + "\\/}";
        else
            return utf8();
    }
@| texUtf8 @}

