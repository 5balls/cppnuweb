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

\section{Classes}
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

@d Generic unit test helper functions
@{@%
  def compare_files(self,file1,file2):
    writtenFile = open(file1,'r')
    writtenLines = writtenFile.readlines()
    expectedFile = open(file2, 'r')
    expectedLines = expectedFile.readlines()
    self.assertEqual(len(writtenLines), len(expectedLines))
    line = 0
    for writtenLine in writtenLines:
      self.assertEqual(writtenLine, expectedLines[line])
      line += 1
@| compare_files @}
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
\subsubsection{nuweb comparison with expected output}
@d nuweb comparison for test @'testname@' with expected output
@{  def test_@1(self):
    stdout, stderr = self.run_nuweb_on_file('test_@1.w')
    self.assertEqual(stderr, '')
    self.compare_files('test_@1.tex', 'test_expected_@1.tex')
@}

\subsubsection{nuweb comparison with expected output and expected file output}
@d nuweb comparison for test @'testname@' with expected output and expected file output
@{  def test_@1(self):
    stdout, stderr = self.run_nuweb_on_file('test_@1.w')
    self.assertEqual(stderr, '')
    self.compare_files('test_@1.tex', 'test_expected_@1.tex')
    self.compare_files('test_@1.txt', 'test_expected_@1.txt')
@}

\subsubsection{nuweb comparison with expected output and \LaTeX{} run}
@d nuweb comparison for test @'testname@' with expected output and \LaTeX{} run
@{  def test_@1(self):
    stdout, stderr = self.run_nuweb_on_file('test_@1.w')
    stdout, stderr = self.run_latex_on_file('test_@1.tex')
    stdout, stderr = self.run_nuweb_on_file('test_@1.w')
    self.assertEqual(stderr, '')
    self.compare_files('test_@1.tex', 'test_expected_@1.tex')
@}

\subsubsection{nuweb comparison with expected output, \LaTeX{} run and expected file output}
@d nuweb comparison for test @'testname@' with expected output, \LaTeX{} run and expected file output
@{  def test_@1(self):
    stdout, stderr = self.run_nuweb_on_file('test_@1.w')
    stdout, stderr = self.run_latex_on_file('test_@1.tex')
    stdout, stderr = self.run_nuweb_on_file('test_@1.w')
    self.assertEqual(stderr, '')
    self.compare_files('test_@1.tex', 'test_expected_@1.tex')
    self.compare_files('test_@1.txt', 'test_expected_@1.txt')
@}
