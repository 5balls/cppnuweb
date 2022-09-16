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

The file class should encapsulate an abstract file view. It should give line / character number access to certain context sensitive features of the file for implementing the language server protocol later.

First we need a class "indexableText" that stores text and gives us access to this text on a line / character basis. For the implementation of the language server protocol we should be able to access the contents in UTF8 as well as UTF16. The internal storage will be in UTF8 and UTF16.

\tododocument{Maybe make member functions utf8 and utf16 protected}

@d Class declaration indexableText
@{
@<Start of class @'indexableText@'@>
private:
    std::vector<std::string> m_utf8Content;
    std::vector<std::u16string> m_utf16Content;
public:
    struct position{
        unsigned int m_line;
        unsigned int m_character;
    };
    struct range{
        position m_from;
        position m_to;
    };
    void addLine(const std::string& line);
    unsigned int numberOfLines() const {return m_utf8Content.size();};
    std::string utf8() const;
    std::string utf8(unsigned int line) const;
    std::string utf8(position fromHereToLineEnding) const;
    std::string utf8(range fromTo) const;
    std::string utf16() const;
    std::string utf16(unsigned int ui_line) const;
    std::string utf16(position fromHereToLineEnding) const;
    std::string utf16(range fromTo) const;
@<End of class@>
@}

Next we want to mark certain parts of the text with arbitrary UTF8 strings. This can be either positions in the text or ranges.

@d Class declaration tagableText
@{
@<Start of class @'tagableText@' base @'indexableText@'@>
private:
    std::vector<range> m_ranges;
    std::map<std::string, std::vector<range* > > m_features;
public:
    void addFeature(const std::string& name, range l_range);

@<End of class@>
@}

\tododocument{Implementations missing}
\tododocument{Adopt functionality for line length and conversion from example in utfcpp}

@O ../src/file.h -d
@{
@<Start of @'FILE@' header@>

#include <vector>
#include <map>
#include "utfcpp-3.2.1/source/utf8.h"
namespace nuweb {
@<Class declaration indexableText@>
@<Class declaration tagableText@>

@<Start of class @'file@' base @'indexableText@'@>
public:
    file(std::string filename);
    static file* byName(const std::string& filename);
private:
    std::string m_filename;
    static std::map<std::string, file*> m_allFiles;
@<End of class, namespace and header@>
@}

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

file* file::byName(const std::string& filename){
    return m_allFiles[filename];
}

void indexableText::addLine(const std::string& line){
    auto endIterator = utf8::find_invalid(line.begin(), line.end());
    if(endIterator != line.end())
        throw std::runtime_error("Invalid UTF8 sequence detected in line " + std::to_string(numberOfLines() + 1));
    m_utf8Content.push_back(line);
    m_utf16Content.push_back(utf8::utf8to16(line));
}
    
std::string indexableText::utf8() const {
    std::string concatenatedString;
    for(auto currentLine: m_utf8Content)
        concatenatedString += currentLine + "\n";
    concatenatedString.pop_back();
    return concatenatedString;
}

std::string indexableText::utf8(unsigned int line) const {
    return m_utf8Content.at(line);
}
    
std::string indexableText::utf8(nuweb::file::position fromHereToLineEnding) const {
    std::string returnString;
    std::string lineString = m_utf8Content.at(fromHereToLineEnding.m_line);
    std::string::iterator currentStringPosition = lineString.begin();
    std::string::iterator endStringPosition = lineString.end();
    utf8::advance(currentStringPosition, fromHereToLineEnding.m_character, endStringPosition);
    while(currentStringPosition != endStringPosition){
        uint32_t currentChar = utf8::next(currentStringPosition, endStringPosition);
        utf8::append(currentChar, std::back_inserter(returnString));
    }
    return returnString;
}

void tagableText::addFeature(const std::string& name, range l_range){
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

