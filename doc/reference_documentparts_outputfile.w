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
        throw std::runtime_error("outputCommand\n");
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
        throw std::runtime_error("AT_SMALL_O not implemented!\n");
    }
    | AT_LARGE_O
    {
        throw std::runtime_error("AT_LARGE_O not implemented!\n");
    }
;
@| outputCommand @}

@d Bison rules
@{
outputFilename
    : TEXT_WITHOUT_AT_OR_WHITESPACE
    {
        throw std::runtime_error("TEXT_WITHOUT_AT_OR_WHITESPACE not implemented!\n");
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
private:
    std::string m_filename;
public:
    outputFile(filePosition* l_filePosition, std::string&& filename) : documentPart(l_filePosition), m_filename(std::move(filename)){
        //std::cout << "outputFile";
        std::cout << "outputFile(" << m_filename << ")\n";
    }
@| outputFile @}
