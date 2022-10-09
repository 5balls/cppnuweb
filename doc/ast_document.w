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

\section{Class document}
\subsection{Interface}
\indexHeader{DOCUMENT}
@O ../src/document.h -d
@{@%
@<Start of @'DOCUMENT@' header@>

#include "documentPart.h"

namespace nuweb {
@<\classDeclaration{document}@>
}
@<End of header@>
@}
\subsection{Implementation}
See @{@<\classDeclaration{document}@>@}.

