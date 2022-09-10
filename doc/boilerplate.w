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

\section{Boilerplate fragments}
\subsection{Headerfiles}
\codecpp
@d Start of @'headername@' header
@{
#ifndef @1_H
#define @1_H
@}

@d End of header
@{
#endif 
@}

\subsection{Classfiles}
\codecpp
@d Start of class @'classname@' base @'baseclass@'
@{
class @1 : public @2
{
@}

@d Start of class @'classname@'
@{
class @1
{
@}

@d End of class
@{
};
@}

@d End of class and header
@{
@<End of class@>
@<End of header@>
@}

@d End of class, namespace and header
@{
@<End of class@>
}
@<End of header@>
@}
