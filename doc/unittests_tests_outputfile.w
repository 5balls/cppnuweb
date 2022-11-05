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

\subsection{Test outputFile}
\indexUnitTest{outputFile}{outputFile}This writes the text to a simple output file. As we run \LaTeX also this time we need to make it a valid document.
\codelatex
@o ../tests/test_outputFile.w
@{@<Start of simple \LaTeX{} document@>
@@o ../tests/test_outputFile.txt
@@{@<Lorem ipsum@>@@}
@<End of simple \LaTeX{} document@>
@}

The \LaTeX output contains some formatting this time.

@o ../tests/test_expected_outputFile.tex
@{@<NW \LaTeX{} definitions@>@<Start of simple \LaTeX{} document@>
@<NW start of file scrap @'1@' target @'1@' title @<NW output file @'../tests/test_outputFile.txt@'@>@>
@<NW verbatim last scrap line @<Lorem ipsum@>@>
@<NW middle of scrap@>

@<NW end of scrap@>
@<End of simple \LaTeX{} document@>
@}

@o ../tests/test_expected_outputFile.txt
@{@<Lorem ipsum@>@}

@d nuweb unit test functions
@{@<nuweb comparison for test @'outputFile@' with expected output, \LaTeX{} run and expected file output@>
@}

\subsection{Test outputFileListingsOption}
\indexUnitTest{outputFile}{outputFileListingsOption}Using the listings option changes the output slightly. We need to use the ``listings'' \LaTeX{} package for this to work.
@o ../tests/test_outputFileListingsOption.w
@{@<Start of listings \LaTeX{} document@>
@@o ../tests/test_outputFileListingsOption.txt
@@{@<Lorem ipsum@>@@}
\end{document}
@}
nuweb writes \lstinline@@\lstinline@@ instead of \lstinline@@\verb@@ inside the scrap now.
@o ../tests/test_expected_outputFileListingsOption.tex
@{@<NW \LaTeX{} definitions@>@<Start of listings \LaTeX{} document@>
@<NW start of file scrap @'1@' target @'1@' title @<NW output file @'../tests/test_outputFileListingsOption.txt@'@>@>
@<NW listings last scrap line @<Lorem ipsum@>@>
@<NW middle of scrap@>

@<NW end of scrap@>
@<End of simple \LaTeX{} document@>
@}

@o ../tests/test_expected_outputFileListingsOption.txt
@{@<Lorem ipsum@>@}

@d nuweb unit test functions
@{@<nuweb (listings) comparison for test @'outputFileListingsOption@' with expected output, \LaTeX{} run and expected file output@>
@}

\subsection{Test outputFileLineBreak}
\indexUnitTest{outputFile}{outputFileLineBreak}Changing the command to `O` changes the output slightly to not use a minipage and create linebreaks.
@o ../tests/test_outputFileLineBreak.w
@{@<Start of simple \LaTeX{} document@>
@@O ../tests/test_outputFileLineBreak.txt
@@{@<Lorem ipsum@>
@<Lorem ipsum@>@@}
\end{document}
@}

@o ../tests/test_expected_outputFileLineBreak.tex
@{@<NW \LaTeX{} definitions@>@<Start of simple \LaTeX{} document@>
@<NW start of LB file scrap @'1@' target @'1@' title @<NW output file @'../tests/test_outputFileLineBreak.txt@'@>@>
@<NW verbatim scrap line @<Lorem ipsum@>@>
@<NW verbatim last scrap line @<Lorem ipsum@>@>
@<NW middle of scrap@>

@<NW end of LB scrap@>
@<End of simple \LaTeX{} document@>
@}

@o ../tests/test_expected_outputFileLineBreak.txt
@{@<Lorem ipsum@>
@<Lorem ipsum@>@}

@d nuweb unit test functions
@{@<nuweb comparison for test @'outputFileLineBreak@' with expected output, \LaTeX{} run and expected file output@>
@}

\subsection{Test outputFileUserIdentifier}
\indexUnitTest{outputFile}{outputFileUserIdentifier}We can use a user identifier on an output file fragment.
@o ../tests/test_outputFileUserIdentifier.w
@{@<Start of simple \LaTeX{} document@>
@@o ../tests/test_outputFileUserIdentifier.txt
@@{@<Lorem ipsum@>
@<Lorem ipsum@>@@| Lorem @@}
\end{document}
@}

@o ../tests/test_expected_outputFileUserIdentifier.tex
@{@<NW \LaTeX{} definitions@>@<Start of simple \LaTeX{} document@>
@<NW start of file scrap @'1@' target @'1@' title @<NW output file @'../tests/test_outputFileUserIdentifier.txt@'@>@>
@<NW verbatim scrap line @<Lorem ipsum@>@>
@<NW verbatim last scrap line @<Lorem ipsum@>@>
@<NW middle of scrap@>
\item \NWtxtIdentsDefed\nobreak\  \verb@@Lorem@@\nobreak\ \NWtxtIdentsNotUsed.
@<NW end of scrap@>
@<End of simple \LaTeX{} document@>
@}

@o ../tests/test_expected_outputFileUserIdentifier.txt
@{@<Lorem ipsum@>
@<Lorem ipsum@>@}

@d nuweb unit test functions
@{@<nuweb comparison for test @'outputFileUserIdentifier@' with expected output, \LaTeX{} run and expected file output@>
@}


\subsection{Test outputFileLineNumbers}
\indexUnitTest{outputFile}{outputFileLineNumbers}
\codelatex
@o ../tests/test_outputFileLineNumbers.w
@{@<Start of simple \LaTeX{} document@>
@@o ../tests/test_outputFileLineNumbers.txt -d
@@{@<Lorem ipsum@>@@}
@<End of simple \LaTeX{} document@>
@}

@o ../tests/test_expected_outputFileLineNumbers.tex
@{@<NW \LaTeX{} definitions@>@<Start of simple \LaTeX{} document@>
@<NW start of file scrap @'1@' target @'1@' title @<NW output file @'../tests/test_outputFileLineNumbers.txt@'@>@>
@<NW verbatim last scrap line @<Lorem ipsum@>@>
@<NW middle of scrap@>

@<NW end of scrap@>
@<End of simple \LaTeX{} document@>
@}

@o ../tests/test_expected_outputFileLineNumbers.txt
@{
#line 4 "test_outputFileLineNumbers.w"
@<Lorem ipsum@>@}

@d nuweb unit test functions
@{@<nuweb comparison for test @'outputFileLineNumbers@' with expected output, \LaTeX{} run and expected file output@>
@}

\subsection{Test outputFileWithFragment}
\indexUnitTest{outputFile}{outputFileWithFragment}
@o ../tests/test_outputFileWithFragment.w
@{@<Start of simple \LaTeX{} document@>
@@o ../tests/test_outputFileWithFragment.txt
@@{@<Lorem ipsum@>@@<Fragment@@>@@}
@@d Fragment
@@{@<Lorem ipsum@>@@}
@<End of simple \LaTeX{} document@>
@}

@o ../tests/test_expected_outputFileWithFragment.tex
@{@<NW \LaTeX{} definitions@>@<Start of simple \LaTeX{} document@>
@<NW start of file scrap @'1@' target @'1a@' title @<NW output file @'../tests/test_outputFileWithFragment.txt@'@>@>
@<NW verbatim last scrap line @{@<Lorem ipsum@>@<NW fragment reference title @'Fragment@' reference @'1b@'@>@}@>
@<NW middle of scrap@>

@<NW end of scrap@>
@<NW start of scrap @'2@' target @'1b@' title @<NW fragment title @'Fragment@'@>@>
@<NW verbatim last scrap line @<Lorem ipsum@>@>
@<NW middle of scrap@>
\item \NWtxtMacroRefIn\ \NWlink{nuweb1a}{1a}.

@<NW end of scrap@>
@<End of simple \LaTeX{} document@>
@}

@o ../tests/test_expected_outputFileWithFragment.txt
@{@<Lorem ipsum@>@<Lorem ipsum@>@}

@d nuweb unit test functions
@{@<nuweb comparison for test @'outputFileWithFragment@' with expected output, \LaTeX{} run and expected file output@>
@}

