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

\section{Document parts}
We have to keep track of the filename and the range we refer to when parsing our document, so let's define a structure for that:

\indexStructure{filePosition}
@d C++ structure definitions in namespace nuweb
@{
struct filePosition {
    filePosition(const std::string& filename,
            unsigned int line, unsigned int column,
            unsigned int line_end, unsigned int column_end):
        m_filename(filename),
        m_line(line), m_column(column),
        m_line_end(line_end), m_column_end(column_end){};
    std::string m_filename;
    unsigned int m_line;
    unsigned int m_column;
    unsigned int m_line_end;
    unsigned int m_column_end;
};
@| filePosition @}

We want to keep this outside of a class, so we can use this as a return type for the lexer as well. The lexer should not know about the higher structures of the document.

As mentioned in the previous section, a ``\codebisonflex\lstinline{documentPart}'' can be ``\lstinline{texCode}'', a ``\lstinline{nuwebExpression}'' or an ``\lstinline{outputFile}'':
\indexBisonRule{documentPart}
@d Bison rules
@{
documentPart
    : texCode
    {
        $$ = $texCode;
    }
    | nuwebExpression
    | outputFile
;
@| documentPart @}

We add the documentPart to our union and define a type based on that union element again:

\indexBisonType{documentPart}
@d Bison type definitions
@{
%type <m_documentPart> documentPart;
@| documentPart @}

\codecpp
@d Bison union definitions
@{
documentPart* m_documentPart;
@| documentPart @}

This is all we need to define our ``\lstinline{class documentPart}''.

\indexClass{documentPart}\indexClassBaseOf{documentPart}{outputFile}\indexClassBaseOf{documentPart}{emptyDocumentPart}
@d \classDeclaration{documentPart}
@{@%
class documentPart: public std::vector<documentPart*> {
private:
    filePosition* m_filePosition = nullptr;
    static bool auxFileParsed;
public:
    documentPart(const documentPart&) = delete;
    documentPart(void) : std::vector<documentPart*>({}) {
    }
    documentPart(documentPart&& l_documentPart) : m_filePosition(l_documentPart.m_filePosition), std::vector<documentPart*>(std::move(l_documentPart)) {
    }
    documentPart(documentPart* l_documentPart) : documentPart(std::move(*l_documentPart)){
    }
    documentPart(filePosition* l_filePosition) : m_filePosition(l_filePosition){
        //std::cout << "documentPart[" << m_filePosition.m_filename << ":" << m_filePosition.m_line << "," << m_filePosition.m_column << "|" << m_filePosition.m_line_end << "," << m_filePosition.m_column_end << ").";
    }
    virtual std::string utf8() const;
    virtual std::string texUtf8() const;
    void setAuxFileParsed(bool wasParsed){
        auxFileParsed = wasParsed;
    }
    static bool auxFileWasParsed(void){
        return auxFileParsed;
    }
};
@| documentPart utf8 texUtf8 @}

@d \staticDefinitions{documentPart}
@{@%
bool nuweb::documentPart::auxFileParsed = false;
@}

@i reference_documentparts_texcode.w

@i reference_documentparts_nuwebexpression.w

@i reference_documentparts_outputfile.w
