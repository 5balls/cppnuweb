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

\subsubsection{Escape character}
@d Lexer rule for escape character
@{@%
<INITIAL,scrapContents,fragmentHeader>[@@][@@] { TOKEN(AT_AT) } @| AT_AT @}

@d \classDeclaration{escapeCharacterDocumentPart}
@{
class escapeCharacterDocumentPart : public documentPart {
private:
    static std::string m_escapementString;
public:
    escapeCharacterDocumentPart(filePosition* l_filePosition) : documentPart(l_filePosition){
    }
    void setEscapeCharacter(const std::string& escape_Character){
        m_escapementString = escape_Character;
    };
    virtual std::string texUtf8(void) const override {
        return m_escapementString;
    }
};
@}

@d \staticDefinitions{escapeCharacterDocumentPart}
@{
std::string nuweb::escapeCharacterDocumentPart::m_escapementString = "@@";
@}



