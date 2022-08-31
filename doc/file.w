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

The file class should encapsulate an abstract file view. It should give line / row number access to certain context sensitive features of the file for implementing the language server protocol later.

@O ../src/file.h -d
@{
@<Start of @'FILE@' header@>
#include "fragments.h"

@<Start of class @'file@'@>
public:
private:
std::string s_filename;
std::vector<std::variant<scrap> > s_fragments;

@<End of class and header@>
@}

@O ../src/file.cpp -d
@{
@}


