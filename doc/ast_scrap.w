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

\section{Class scrap}
\subsection{Interface}
@d \classDeclaration{scrap}
@{@%
class scrap : public documentPart {
public:
    scrap(const scrap&) = delete;
    scrap(scrap&& l_scrap) : documentPart(std::move(l_scrap)){
    }
    scrap(documentPart* l_documentPart) : documentPart(l_documentPart){
    }
};
@| scrap @}
