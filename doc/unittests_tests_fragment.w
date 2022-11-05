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
\indexUnitTest{fragment}{fragment}
@o ../tests/test_fragment.w
@{@<Start of simple \LaTeX{} document@>
@@d Fragment
@@{@<Lorem ipsum@>
@@}
@<End of simple \LaTeX{} document@>
@}

@o ../tests/test_expected_fragment.tex
@{@<NW \LaTeX{} definitions@>@<Start of simple \LaTeX{} document@>
@<NW start of scrap @'1@' target @'1@' title @<NW fragment title @'Fragment@'@>@>
@<NW verbatim scrap line @<Lorem ipsum@>@>
@<NW verbatim last scrap line @'@'@>
@<NW middle of scrap@>
@<NW no scrap references@>

@<NW end of scrap@>
@<End of simple \LaTeX{} document@>
@}
@d nuweb unit test functions
@{@<nuweb comparison for test @'fragment@' with expected output and \LaTeX{} run@>
@}

\subsection{Test fragmentArgumentString}
\indexUnitTest{fragment}{fragmentArgumentString}This is the first of four type of arguments which can be passed to a fragment. The string is just copied literally to the output.
@o ../tests/test_fragmentArgumentString.w
@{@<Start of simple \LaTeX{} document@>
@@d Fragment @@'argument@@'
@@{@<Lorem ipsum@>@@1@@}
@<End of simple \LaTeX{} document@>
@}

@o ../tests/test_expected_fragmentArgumentString.tex
@{@<NW \LaTeX{} definitions@>@<Start of simple \LaTeX{} document@>
@<NW start of scrap @'1@' target @'1@' title @<NW fragment title @{Fragment @<NW argument @'argument@'@>@}@>@>
@<NW verbatim last scrap line @{@<Lorem ipsum@>@@@<NW argument @'argument@'@>\verb@@@}@>
@<NW middle of scrap@>
@<NW no scrap references@>

@<NW end of scrap@>
@<End of simple \LaTeX{} document@>
@}
@d nuweb unit test functions
@{@<nuweb comparison for test @'fragmentArgumentString@' with expected output and \LaTeX{} run@>
@}

\subsection{Test fragmentArgumentStringExpansion}
\indexUnitTest{fragment}{fragmentArgumentStringExpansion}
@o ../tests/test_fragmentArgumentStringExpansion.w
@{@<Start of simple \LaTeX{} document@>
@@d Fragment @@'argument@@'
@@{@<Lorem ipsum@>@@1@@}
@@<Fragment @@'Expanded argument@@'@@>
@<End of simple \LaTeX{} document@>
@}

@o ../tests/test_expected_fragmentArgumentStringExpansion.tex
@{@<NW \LaTeX{} definitions@>@<Start of simple \LaTeX{} document@>
@<NW start of scrap @'1@' target @'1@' title @<NW fragment title @{Fragment @<NW argument @'argument@'@>@}@>@>
@<NW verbatim last scrap line @{@<Lorem ipsum@>@@@<NW argument @'argument@'@>\verb@@@}@>
@<NW middle of scrap@>
@<NW no scrap references@>

@<NW end of scrap@>
@<Lorem ipsum@>Expanded argument
@<End of simple \LaTeX{} document@>
@}
@d nuweb unit test functions
@{@<nuweb comparison for test @'fragmentArgumentStringExpansion@' with expected output and \LaTeX{} run@>
@}

\subsection{Test fragmentArgumentStringExpansionInOtherFragment}
\indexUnitTest{fragment}{fragmentArgumentStringExpansionInOtherFragment}
@o ../tests/test_fragmentArgumentStringExpansionInOtherFragment.w
@{@<Start of simple \LaTeX{} document@>
@@d Fragment @@'argument@@'
@@{@<Lorem ipsum@>@@1@@}
@@d Second fragment
@@{@@<Fragment @@'Expanded argument@@'@@>@@}
@<End of simple \LaTeX{} document@>
@}

@o ../tests/test_expected_fragmentArgumentStringExpansionInOtherFragment.tex
@{@<NW \LaTeX{} definitions@>@<Start of simple \LaTeX{} document@>
@<NW start of scrap @'1@' target @'1a@' title @<NW fragment title @{Fragment @<NW argument @'argument@'@>@}@>@>
@<NW verbatim last scrap line @{@<Lorem ipsum@>@@@<NW argument @'argument@'@>\verb@@@}@>
@<NW middle of scrap@>
@<NW referenced in @'1b@'@>

@<NW end of scrap@>
@<NW start of scrap @'2@' target @'1b@' title @<NW fragment title @'Second fragment@'@>@>
@<NW verbatim last scrap line @<NW fragment reference title @'Fragment \verb@@Expanded argument@@@' reference @'1a@'@>@>
@<NW middle of scrap@>
@<NW no scrap references@>

@<NW end of scrap@>
@<End of simple \LaTeX{} document@>
@}
@d nuweb unit test functions
@{@<nuweb comparison for test @'fragmentArgumentStringExpansionInOtherFragment@' with expected output and \LaTeX{} run@>
@}

