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

\chapter{File and related classes}

The file class should encapsulate an abstract file view. It should give line / character number access to certain context sensitive features of the file for implementing the language server protocol later. We define some helper classes (like \codecpp\lstinline{class indexableText} and \lstinline{class tagableText}) from which we inherit.

\section{Class indexableText}
First we need a class "indexableText" that stores text and gives us access to this text on a line / character basis. For the implementation of the language server protocol we should be able to access the contents in UTF8 as well as UTF16. The internal storage will be in UTF8 and UTF16.

We need to have getter methods which return \codecpp\lstinline{std::stringstream} as well. Right now those are just calling the \lstinline{std::string} methods which is not very good performance wise as \lstinline{std::stringstream::stringstream(const std::string&)} performs a copy of the string (which may be a huge file) but lets go with this for now.

\todorefactor{Implement better getter methods for \lstinline{std::stringstream} in \lstinline{class indexableText}.}

\tododocument{Maybe make member functions utf8 and utf16 protected}

\subsection{Interface}
Our class in line based. This has advantages when trying to index UTF-8 code, because we only have to check the length of codepoints before the filePositions in the line (as UTF-8 is variable length we can't directly index the filePositions).

We store the lines in UTF-16 as well because we need to be able to return UTF-16 for the implementation of the Language Server Protocol:

\indexClass{indexableText}\indexClassBaseOf{indexableText}{tagableText}\indexClassBaseOf{indexableText}{file}
@D Class declaration indexableText
@{
@<Start of class @'indexableText@'@>
private:
    std::vector<std::string> m_utf8Content;
    std::vector<std::u16string> m_utf16Content;
@}

Maybe we need the constructor after all:

@D Class declaration indexableText
@{
public:
    indexableText() : m_utf8Content({}), m_utf16Content({}){
        std::cout << "indexableText()\n";
    };
@}

We define some simple filePosition and range structure here:

@D Class declaration indexableText
@{
public:
    struct filePosition{
        unsigned int m_line;
        unsigned int m_character;
    };
    struct range{
        filePosition m_from;
        filePosition m_to;
    };
@}

Currently \lstinline{addLine} is the only way to get data into the class:

@D Class declaration indexableText
@{
    void addLine(const std::string& line);
@}

For the getter methods we have several overloaded functions. We need to have them with return value \lstinline{std::stringstream} as well because we need it for the lexer class.

@D Class declaration indexableText
@{
    unsigned int numberOfLines() const {return m_utf8Content.size();};
    std::string utf8() const;
    std::string utf8(const unsigned int line) const;
    std::string utf8(const range& fromTo) const;
    std::string utf8TillLineEnd(const filePosition& fromHereToLineEnding) const;
    std::string utf8FromLineBeginning(const filePosition& fromLineBeginningToHere) const;
    std::string utf8FromToInLine(const range& fromTo) const;
@}

The same for UTF-16:

@D Class declaration indexableText
@{
    std::string utf16() const;
    std::string utf16(unsigned int ui_line) const;
    std::string utf16(const filePosition& fromHereToLineEnding) const;
    std::string utf16(const range& fromTo) const;
@<End of class@>
@}

\subsection{Implementation}
\indexClassMethod{indexableText}{addLine}
@d Implementation of class indexableText
@{
void indexableText::addLine(const std::string& line){
    auto endIterator = utf8::find_invalid(line.begin(), line.end());
    if(endIterator != line.end())
        throw std::runtime_error("Invalid UTF8 sequence detected in line " + std::to_string(numberOfLines() + 1));
    m_utf8Content.push_back(line);
    m_utf16Content.push_back(utf8::utf8to16(line));
}
@}

\indexClassMethod{indexableText}{utf8}
@d Implementation of class indexableText
@{
std::string indexableText::utf8() const {
    std::string concatenatedString = "";
    for(unsigned int line=0; line<m_utf8Content.size(); line++)
        concatenatedString += utf8(line) + "\n";
    concatenatedString.pop_back();
    return concatenatedString;
}
@}

@d Implementation of class indexableText
@{
std::string indexableText::utf8(const unsigned int line) const {
    return m_utf8Content.at(line);
}
@}

\indexClassMethod{indexableText}{utf8TillLineEnd}
@d Implementation of class indexableText
@{
std::string indexableText::utf8TillLineEnd(const filePosition& fromHere) const {
    std::string returnString;
    std::string lineString = m_utf8Content.at(fromHere.m_line);
    std::string::iterator currentStringPosition = lineString.begin();
    std::string::iterator endStringPosition = lineString.end();
    utf8::advance(currentStringPosition, fromHere.m_character, endStringPosition);
    while(currentStringPosition != endStringPosition){
        uint32_t currentChar = utf8::next(currentStringPosition, endStringPosition);
        utf8::append(currentChar, std::back_inserter(returnString));
    }
    return returnString;
}
@}

\indexClassMethod{indexableText}{utf8FromLineBeginning}
@d Implementation of class indexableText
@{
std::string indexableText::utf8FromLineBeginning(const filePosition& toHere) const {
    std::string returnString;
    std::string lineString = m_utf8Content.at(toHere.m_line);
    std::string::iterator endStringPosition = lineString.end();
    std::string::iterator currentStringPosition = lineString.begin();
    unsigned int currentCharIndex = 0;
    while(currentCharIndex != toHere.m_character){
        uint32_t currentChar = utf8::next(currentStringPosition, endStringPosition);
        utf8::append(currentChar, std::back_inserter(returnString));
        currentCharIndex++;
    }
    return returnString;
}
@}

\indexClassMethod{indexableText}{utf8FromToInLine}
@d Implementation of class indexableText
@{
std::string indexableText::utf8FromToInLine(const range& fromTo) const {
    std::string returnString;
    std::string lineString = m_utf8Content.at(fromTo.m_from.m_line);
    std::string::iterator currentStringPosition = lineString.begin();
    std::string::iterator endStringPosition = lineString.end();
    utf8::advance(currentStringPosition, fromTo.m_from.m_character, endStringPosition);
    unsigned int currentCharIndex = 0;
    while(currentCharIndex <= fromTo.m_to.m_character){
        uint32_t currentChar = utf8::next(currentStringPosition, endStringPosition);
        utf8::append(currentChar, std::back_inserter(returnString));
        currentCharIndex++;
    }
    return returnString;
}
@}

\indexClassMethod{indexableText}{utf8}
@d Implementation of class indexableText
@{
std::string indexableText::utf8(const range& fromTo) const {
    unsigned int firstLine = fromTo.m_from.m_line;
    unsigned int lastLine = fromTo.m_to.m_line;
    std::string returnString;
    for(unsigned int lineNumber = firstLine; lineNumber < lastLine; lineNumber++){
        if(firstLine == lastLine)
            return utf8FromToInLine(fromTo);
        if((lineNumber == firstLine) && (fromTo.m_from.m_character > 0)){
            returnString += utf8TillLineEnd(fromTo.m_from) + "\n";
            continue;
        }
        if(lineNumber == lastLine){
            returnString += utf8FromLineBeginning(fromTo.m_to) + "\n";
            continue;
        }
        returnString += m_utf8Content.at(lineNumber);
    }
    returnString.pop_back();
    return returnString;
}
@}

\section{Class tagableText}

Next we want to mark certain parts of the text with arbitrary UTF8 strings. This can be either filePositions in the text or ranges.
\subsection{Interface}
\indexClass{tagableText}
@d Class declaration tagableText
@{
@<Start of class @'tagableText@' base @'indexableText@'@>
private:
    std::vector<range> m_ranges;
    std::map<std::string, std::vector<range* > > m_features;
public:
    void addFeature(const std::string& name, const range& l_range);

@<End of class@>
@}
\subsection{Implementation}
\indexClassMethod{tagableText}{addFeature}
@d Implementation of class tagableText
@{
void tagableText::addFeature(const std::string& name, const range& l_range){
    m_ranges.push_back(l_range);
    if(m_features.find(name) != m_features.end())
        m_features[name].push_back(&m_ranges.back());
    else{
        std::vector<range*> rangeVector;
        rangeVector.push_back(&m_ranges.back());
        m_features[name] = rangeVector;
    }
}
@}

\tododocument{Implementations missing}
\tododocument{Adopt functionality for line length and conversion from example in utfcpp}

\section{Files}
\subsection{Header}
\indexHeader{FILE}
@O ../src/file.h -d
@{
@<Start of @'FILE@' header@>

#include <vector>
#include <map>
#include "utfcpp-3.2.1/source/utf8.h"
#include <sstream>
#include <iostream>

namespace nuweb {
@<Class declaration indexableText@>
@<Class declaration tagableText@>
@}

\indexClass{file}
@O ../src/file.h -d
@{
@<Start of class @'file@' base @'indexableText@'@>
public:
    file(std::string filename);
    static file* byName(const std::string& filename);
private:
    std::string m_filename;
    static std::map<std::string, file*> m_allFiles;
@<End of class, namespace and header@>
@}
\subsection{Source}
@O ../src/file.cpp -d
@{
#include "file.h"
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <iterator>

using namespace nuweb;

std::map<std::string, file*> file::m_allFiles = {};

file::file(std::string filename) : m_filename(filename){
    std::ifstream fileStream(m_filename);
    if(!fileStream.is_open())
        throw std::runtime_error("Could not open file \"" + m_filename + "\"");
    std::string line;
    while(std::getline(fileStream, line))
        addLine(line);
    m_allFiles[filename] = this;
}
@}

\indexClassMethod{file}{byName}
@O ../src/file.cpp -d
@{
file* file::byName(const std::string& filename){
    return m_allFiles[filename];
}
@<Implementation of class indexableText@>
@<Implementation of class tagableText@>
@}


