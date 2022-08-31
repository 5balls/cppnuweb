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

\chapter{Fragments}

The fragment class is the base class of any indexable text fragment. This can be of different language type and should provide different output functions for creating text for the \LaTeX and for the language file in UTF-8 and UTF-16.

@O ../src/fragments.h -d
@{
@<Start of @'FRAGMENTS@' header@>
@<Start of class @'fragment@'@>
public:
enum class e_features{
    LABEL,
};
struct t_position{
    unsigned int ui_row;
    unsigned int ui_column;
};
protected:
struct t_range{
    t_position t_start;
    t_position t_end;
};
t_range t_fragmentRange;
std::vector<t_range> v_ranges;
std::map<e_feature, std::vector<t_range& > > m_features;
@<End of class@>

@<Start of class @'scrap@' base @'fragment@'@>
@<End of class and header@>
@}

