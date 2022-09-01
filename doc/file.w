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

\chapter{File}

The file class should encapsulate an abstract file view. It should give line / character number access to certain context sensitive features of the file for implementing the language server protocol later.

First we need a class "indexabletext" that stores text and gives us access to this text on a line / character basis. For the implementation of the language server protocol we should be able to access the contents in UTF8 as well as UTF16. The internal storage will be in UTF8.

@d Class declaration indexabletext
@{
@<Start of class @'indexabletext@'@>
private:
    std::string s_utf8Content;
    std::vector<int> vi_lineLengthUtf8;
    std::vector<int> vi_lineLengthUtf16;
public:
    indexabletext(std::string s_initialText, std::vector<std::string> vs_lineDelimiters);
    struct t_position{
        unsigned int ui_line;
        unsigned int ui_character;
    };
    struct t_range{
        t_position t_start;
        t_position t_end;
    };
    std::string utf8();
    std::string utf8(t_position tp_fromHereToLineEnding);
    std::string utf8(t_range tr_fromTo);
    std::string utf16();
    std::string utf16(t_position tp_fromHereToLineEnding);
    std::string utf16(t_range tr_fromTo);
@<End of class@>
@}

Next we want to mark certain parts of the text with arbitrary UTF8 strings. This can be either positions in the text or ranges.

\tododocument{Implementation missing}

@O ../src/file.h -d
@{
@<Start of @'FILE@' header@>
#include "fragments.h"
@<Class declaration indexabletext@>

@<Start of class @'file@' base @'indexabletext@'@>
public:
private:
std::string s_filename;
std::vector<std::variant<scrap> > s_fragments;

@<End of class and header@>
@}

@O ../src/file.cpp -d
@{
@}


