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

\subsection{Test fragment}
\index{fragment}{fragment}
@o ../tests/test_fragment.w
@{@<Start of simple \LaTeX{} document@>
@@d Fragment
@@{@<Lorem ipsum@>
@@}
@<End of simple \LaTeX{} document@>
@}

@o ../tests/test_expected_fragment.tex
@{@<Nuweb \LaTeX{} definitions@>@<Start of simple \LaTeX{} document@>
\begin{flushleft} \small
\begin{minipage}{\linewidth}\label{scrap1}\raggedright\small
\NWtarget{nuweb1}{} $\langle\,${\itshape Fragment}\nobreak\ {\footnotesize {1}}$\,\rangle\equiv$
\vspace{-1ex}
\begin{list}{}{} \item
\mbox{}\verb@@@<Lorem ipsum@>@@\\
\mbox{}\verb@@@@{\NWsep}
\end{list}
\vspace{-1.5ex}
\footnotesize
\begin{list}{}{\setlength{\itemsep}{-\parsep}\setlength{\itemindent}{-\leftmargin}}
\item {\NWtxtMacroNoRef}.

\item{}
\end{list}
\end{minipage}\vspace{4ex}
\end{flushleft}
@<End of simple \LaTeX{} document@>
@}
@d nuweb unit test functions
@{@<nuweb comparison for test @'fragment@' with expected output and \LaTeX{} run@>
@}
