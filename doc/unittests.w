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

\chapter{Unit tests}
This unit tests use python. They test the output of various nuweb constructs and the combination of constructs by running nuweb on a nuweb file and comparing the written output file to an expected output file.

\section{Class nuwebUnitTests}
\codepython
@o ../tests/tests.py
@{@%
@<Unit test imports@>

class cppNuwebUnitTests(unittest.TestCase):
@<Generic unit test helper functions@>
@<C++ nuweb unit test helper functions@>
@<nuweb unit test functions@>

class cNuwebUnitTests(unittest.TestCase):
@<Generic unit test helper functions@>
@<C nuweb unit test helper functions@>
@<nuweb unit test functions@>

if __name__ == '__main__':
  unittest.main()
@| nuwebUnitTests @}

\subsection{Imports}
We use the ``unittest'' framework of python and use ``subprocess'' to spawn a shell process.
@d Unit test imports
@{@%
import unittest
import subprocess
@}

\subsection{Helper functions}
\subsubsection{Version specific}
@d C++ nuweb unit test helper functions
@{@%
  def run_nuweb_on_file(self,filename):
    return self.spawn_shell_command('../build/x64/nuweb', filename)
@| run_nuweb_on_file @}
@d C nuweb unit test helper functions
@{@%
  def run_nuweb_on_file(self,filename):
    return self.spawn_shell_command('nuweb', filename)
@| run_nuweb_on_file @}
\subsubsection{Generic}
@d Generic unit test helper functions
@{@%
  def spawn_shell_command(self,command,filename):
    process = subprocess.Popen([command, filename],
                         stdout=subprocess.PIPE,
                         stderr=subprocess.PIPE)
    return process.communicate()
@| spawn_shell_command @}
@d Generic unit test helper functions
@{@%
  def run_latex_on_file(self,filename):
    return self.spawn_shell_command('pdflatex', filename)
@| run_latex_on_file @}

\subsection{Helper text blocks}
\subsubsection{Lorem ipsum}
@d Lorem ipsum
@{Lorem ipsum dolor sit amet, consectetur adipisici elit, sed eiusmod tempor incidunt ut labore et dolore magna aliqua.@}
\subsubsection{Nuweb \LaTeX{} definitions}
@d Nuweb \LaTeX{} definitions
@{\newcommand{\NWtarget}[2]{#2}
\newcommand{\NWlink}[2]{#2}
\newcommand{\NWtxtMacroDefBy}{Fragment defined by}
\newcommand{\NWtxtMacroRefIn}{Fragment referenced in}
\newcommand{\NWtxtMacroNoRef}{Fragment never referenced}
\newcommand{\NWtxtDefBy}{Defined by}
\newcommand{\NWtxtRefIn}{Referenced in}
\newcommand{\NWtxtNoRef}{Not referenced}
\newcommand{\NWtxtFileDefBy}{File defined by}
\newcommand{\NWtxtIdentsUsed}{Uses:}
\newcommand{\NWtxtIdentsNotUsed}{Never used}
\newcommand{\NWtxtIdentsDefed}{Defines:}
\newcommand{\NWsep}{${\diamond}$}
\newcommand{\NWnotglobal}{(not defined globally)}
\newcommand{\NWuseHyperlinks}{}
@}

\subsection{Test templates}
\subsubsection{File output comparison}
@d File output comparison for test @'filename@'
@{    writtenFile = open('test_@1.tex','r')
    writtenLines = writtenFile.readlines()
    expectedFile = open('test_expected_@1.tex', 'r')
    expectedLines = expectedFile.readlines()
    self.assertEqual(len(writtenLines), len(expectedLines))
    line = 0
    for writtenLine in writtenLines:
      self.assertEqual(writtenLine, expectedLines[line])
      line += 1@}
\subsubsection{nuweb comparison with expected output}
@d nuweb comparison for test @'testname@' with expected output
@{  def test_@1(self):
    stdout, stderr = self.run_nuweb_on_file('test_@1.w')
    self.assertEqual(stderr, '')
@<File output comparison for test @1@>
@}
\subsubsection{nuweb comparison with expected output and \LaTeX{} run}
@d nuweb comparison for test @'testname@' with expected output and \LaTeX{} run
@{  def test_@1(self):
    stdout, stderr = self.run_nuweb_on_file('test_@1.w')
    stdout, stderr = self.run_latex_on_file('test_@1.tex')
    stdout, stderr = self.run_nuweb_on_file('test_@1.w')
    self.assertEqual(stderr, '')
@<File output comparison for test @1@>
@}

\section{Tests}
\subsection{Text without any nuweb command}
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

\subsection{Text with @@@@}
This text contains ``@@@@'' which should be replaced by ``@@''.

@o ../tests/test_textWithAtAt.w
@{Text with @@@@.
@}

@o ../tests/test_expected_textWithAtAt.tex
@{@<Nuweb \LaTeX{} definitions@>Text with @@.
@}

@d nuweb unit test functions
@{@<nuweb comparison for test @'textWithAtAt@' with expected output@>
@}

\subsection{Output file}
This writes the text to a simple output file. As we run \LaTeX also this time we need to make it a valid document.

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

@d nuweb unit test functions
@{@<nuweb comparison for test @'outputFile@' with expected output and \LaTeX{} run@>
@}

