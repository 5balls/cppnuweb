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

\section{Tests}
\subsection{Test textWithoutAnyNuwebCommand}
This test is a simple passthrough test where no nuweb commands are used.

@o ../tests/test_textWithoutAnyNuwebCommand.w
@{@<Lorem ipsum@>
@}

Nuweb should not modify the input text but add latex definitions in front of the text.

@o ../tests/test_expected_textWithoutAnyNuwebCommand.tex
@{@<Nuweb \LaTeX{} definitions@>@<Lorem ipsum@>
@}

@d nuweb unit test functions
@{@<nuweb comparison for test @'textWithoutAnyNuwebCommand@' with expected output@>
@}

\subsection{Test textWithAtAt}
\indexUnitTest{AT\_AT}{textWithAtAt}This text contains ``@@@@'' which should be replaced by ``@@''.

@o ../tests/test_textWithAtAt.w
@{Text with @@@@.
@}

@o ../tests/test_expected_textWithAtAt.tex
@{@<Nuweb \LaTeX{} definitions@>Text with @@.
@}

@d nuweb unit test functions
@{@<nuweb comparison for test @'textWithAtAt@' with expected output@>
@}

\subsection{Test outputFile}
\indexUnitTest{outputFile}{outputFile}This writes the text to a simple output file. As we run \LaTeX also this time we need to make it a valid document.

@o ../tests/test_outputFile.w
@{\documentclass{article}
\begin{document}
@@o ../tests/test_outputFile.txt
@@{@<Lorem ipsum@>@@}
\end{document}
@}

The \LaTeX output contains some formatting this time.

@o ../tests/test_expected_outputFile.tex
@{@<Nuweb \LaTeX{} definitions@>\documentclass{article}
\begin{document}
\begin{flushleft} \small
\begin{minipage}{\linewidth}\label{scrap1}\raggedright\small
\NWtarget{nuweb1}{} \verb@@"../tests/test_outputFile.txt"@@\nobreak\ {\footnotesize {1}}$\equiv$
\vspace{-1ex}
\begin{list}{}{} \item
\mbox{}\verb@@@<Lorem ipsum@>@@{\NWsep}
\end{list}
\vspace{-1.5ex}
\footnotesize
\begin{list}{}{\setlength{\itemsep}{-\parsep}\setlength{\itemindent}{-\leftmargin}}

\item{}
\end{list}
\end{minipage}\vspace{4ex}
\end{flushleft}
\end{document}
@}

@o ../tests/test_expected_outputFile.txt
@{@<Lorem ipsum@>@}

@d nuweb unit test functions
@{@<nuweb comparison for test @'outputFile@' with expected output, \LaTeX{} run and expected file output@>
@}

\subsection{Test outputFileListingsOption}
\indexUnitTest{outputFile}{outputFileListingsOption}Using the listings option changes the output slightly. We need to use the ``listings'' \LaTeX{} package for this to work.
@o ../tests/test_outputFileListingsOption.w
@{\documentclass{article}
\usepackage{listings}
\begin{document}
@@o ../tests/test_outputFileListingsOption.txt
@@{@<Lorem ipsum@>@@}
\end{document}
@}
nuweb writes \verb@@\lstinline@@ instead of \verb@@\verb@@ inside the scrap now.
@o ../tests/test_expected_outputFileListingsOption.tex
@{@<Nuweb \LaTeX{} definitions@>\documentclass{article}
\usepackage{listings}
\begin{document}
\begin{flushleft} \small
\begin{minipage}{\linewidth}\label{scrap1}\raggedright\small
\NWtarget{nuweb1}{} \verb@@"../tests/test_outputFileListingsOption.txt"@@\nobreak\ {\footnotesize {1}}$\equiv$
\vspace{-1ex}
\begin{list}{}{} \item
\mbox{}\lstinline@@@<Lorem ipsum@>@@{\NWsep}
\end{list}
\vspace{-1.5ex}
\footnotesize
\begin{list}{}{\setlength{\itemsep}{-\parsep}\setlength{\itemindent}{-\leftmargin}}

\item{}
\end{list}
\end{minipage}\vspace{4ex}
\end{flushleft}
\end{document}
@}

@o ../tests/test_expected_outputFileListingsOption.txt
@{@<Lorem ipsum@>@}

@d nuweb unit test functions
@{@<nuweb (listings) comparison for test @'outputFileListingsOption@' with expected output, \LaTeX{} run and expected file output@>
@}
