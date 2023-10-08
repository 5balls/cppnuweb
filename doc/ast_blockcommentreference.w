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

\section{Class blockCommentReference}
\subsection{Interface}
\indexClass{blockCommentReference}
@d \classDeclaration{blockCommentReference}
@{@%
class blockCommentReference : public emptyDocumentPart {
private:
    blockComment* m_lastBlockComment; 
public:
    blockCommentReference(void);
    virtual std::string texUtf8(void) const override;
    virtual std::string fileUtf8(filePosition& l_filePosition) const override;
};
@| blockCommentReference @}

\subsubsection{blockCommentReference}
\indexClassMethod{blockCommentReference}{blockCommentReference}
@d \classImplementation{blockCommentReference}
@{@%
    nuweb::blockCommentReference::blockCommentReference(void) : emptyDocumentPart(), m_lastBlockComment(blockComment::lastBlockComment()){
        
    }
@| blockCommentReference @}

\subsubsection{texUtf8}
\indexClassMethod{blockCommentReference}{texUtf8}
@d \classImplementation{blockCommentReference}
@{@%
    std::string nuweb::blockCommentReference::texUtf8(void) const{
        return "@@\\hbox{\\sffamily\\slshape (Comment)}\\verb@@";
    }
@| texUtf8 @}
\subsubsection{fileUtf8}
\indexClassMethod{blockCommentReference}{fileUtf8}
@d \classImplementation{blockCommentReference}
@{@%
    std::string nuweb::blockCommentReference::fileUtf8(filePosition& l_filePosition) const{
        std::string commentStart, commentMiddle, commentMiddleEnd, commentEnd;
        for(const auto& flag: outputFile::currentFlags()){
            switch(flag){
                case outputFileFlags::C_COMMENTS:
                    m_commentStyle = flag;
                    commentStart = "/*";
                    commentMiddle = " *";
                    commentMiddleEnd = "/";
                    commentEnd = " */";
                    break;
                case outputFileFlags::CPP_COMMENTS:
                    m_commentStyle = flag;
                    commentStart = "//";
                    commentMiddle = "//";
                    commentMiddleEnd = "";
                    commentEnd = "";
                    break;
                case outputFileFlags::PERL_COMMENTS:
                    m_commentStyle = flag;
                    commentStart = "#";
                    commentMiddle = "#";
                    commentMiddleEnd = "";
                    commentEnd = "";
                    break;
                default:
                    break;
            }
        }

        if(m_lastBlockComment){
            unsigned int indentation = l_filePosition.m_column;
            std::string returnString = indexableText::progressFilePosition(l_filePosition, commentStart);

            filePosition ll_filePosition("",1,documentPart::m_fileIndentation+1,1,1);
            std::string commentRawString = m_lastBlockComment->utf8(ll_filePosition);
            commentRawString.erase(0,1);
            size_t lastWordSeparator = 0;
            size_t wordSeparator = commentRawString.find_first_of(" \n");
            size_t doubleNewline = 0;
            bool extraLineBreak = false;
            while(wordSeparator != std::string::npos){
                if(doubleNewline == wordSeparator && (doubleNewline != 0))
                    extraLineBreak = true;
                std::string word = " " + commentRawString.substr(lastWordSeparator, wordSeparator-lastWordSeparator);
                while(word.back() == '\n' || word.back() == ' ')
                    word.pop_back();
                lastWordSeparator = wordSeparator + 1;
                doubleNewline = commentRawString.find("\n\n", wordSeparator+1);
                wordSeparator = commentRawString.find_first_of(" \n", wordSeparator+1);
                unsigned int wordLength = utf8::distance(word.begin(), word.end());
                returnString += indexableText::progressFilePosition(l_filePosition, word);
                if(wordLength == 0)
                    continue;
                if(l_filePosition.m_column > 60)
                    returnString += indexableText::progressFilePosition(l_filePosition, "\n" + std::string(indentation, ' ') + commentMiddle);
                if(extraLineBreak){
                    extraLineBreak = false;
                    returnString += indexableText::progressFilePosition(l_filePosition, "\n" + std::string(indentation, ' ') + commentMiddle);
                }
            }
            if(l_filePosition.m_column == 0)
                returnString += std::string(indentation, ' ') + indexableText::progressFilePosition(l_filePosition, commentEnd);
            else if(l_filePosition.m_column == indentation + commentMiddle.length()){
                switch(m_commentStyle){
                    case outputFileFlags::C_COMMENTS:
                        returnString += indexableText::progressFilePosition(l_filePosition, commentMiddleEnd);
                        break;
                    case outputFileFlags::CPP_COMMENTS:
                        returnString.pop_back();
                        returnString.pop_back();
                        break;
                    case outputFileFlags::PERL_COMMENTS:
                        returnString.pop_back();
                        break;
                    default:
                        break;
                }

            }
            else
                returnString += indexableText::progressFilePosition(l_filePosition, " " + commentEnd);
            return returnString;
        }
        else
            return "";
    }
@| fileUtf8 @}
