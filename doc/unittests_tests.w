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

@i unittests_tests_outputfile.w

@i unittests_tests_fragment.w
