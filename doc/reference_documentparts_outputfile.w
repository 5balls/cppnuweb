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

\subsection{Output file}
@d Bison rules
@{
outputFile
    : outputCommand WHITESPACE outputFilename WHITESPACE scrap
    {
        switch($outputCommand){
            case fragmentType::OUTPUT_FILE:
                $$ = new outputFile(new documentPart($outputFilename), $scrap);
                break;
            case fragmentType::OUTPUT_FILE_PAGEBREAK:
            default:
                $$ = new outputFile(new documentPart($outputFilename), $scrap, true);
                break;
        }
    }
    | outputCommand WHITESPACE outputFilename WHITESPACE outputFlags WHITESPACE scrap
    {
        throw std::runtime_error("outputCommand with filename <hidden in file class somewhere> and flags\n");
    }
;
@| outputFile @}

@d Bison type definitions
@{%type <m_filePosition> outputFilename;
@| outputFilename @}

@d Bison rules
@{
outputCommand
    : AT_SMALL_O
    {
        $$ = fragmentType::OUTPUT_FILE;
    }
    | AT_LARGE_O
    {
        $$ = fragmentType::OUTPUT_FILE_PAGEBREAK;
    }
;
@| outputCommand @}

@d Bison type definitions
@{@%
%type <m_fragmentType> outputCommand
@| outputCommand @}

@d Bison rules
@{
outputFilename
    : TEXT_WITHOUT_AT_OR_WHITESPACE
    {
        $$ = $TEXT_WITHOUT_AT_OR_WHITESPACE;
    }
;
@| outputFilename @}

@d Bison rules
@{
outputFlags
    : MINUS_D
    {
        throw std::runtime_error("MINUS_D not implemented!\n");
    }
;
@| outputFlags @}

\indexClass{outputFile}\todoimplement{Output function for file contents}
@d \classDeclaration{outputFile}
@{
class outputFile: public fragmentDefinition {
private:
    std::string m_filename;
public:
    outputFile(documentPart* l_fileName, documentPart* l_scrap, bool pageBreak = false) : fragmentDefinition(l_fileName, l_scrap, pageBreak) {
        m_filename = l_fileName->utf8();
    }
    virtual std::string headerTexUtf8(void) const override {
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
    virtual std::string referencesTexUtf8(void) const override {
        return "";
    }
};
@| outputFile @}
