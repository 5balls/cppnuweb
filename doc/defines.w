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

\lstdefinelanguage{CMake}{
  keywords={cmake_minimum_required, if, endif, include, project, set, execute\_process, cmake\_print\_variables, add\_definitions, find\_package, include\_directories, add\_library, else, add\_executable, target\_link\_libraries, install, message},
  morecomment=[l]{//},
  morecomment=[s]{/*}{*/},
  morestring=[b]',
  morestring=[b]",
  ndkeywords={},
  keywordstyle=\bfseries,
  ndkeywordstyle=\bfseries,
  identifierstyle=\color{black},
  commentstyle=\ttfamily,
  stringstyle=\ttfamily,
  sensitive=true
}

\lstdefinelanguage{bisonflex}{
  morekeywords={\%option, \%x, \%\{, \%\}, \%\%, \%require, \%language, \%code, requires, \%lex-param, \%parse-param, \%token, \%union, \%empty, \%type},
  alsoletter={\%\{\}-},
  morecomment=[l]{//},
  morecomment=[s]{/*}{*/},
  morestring=[b]',
  morestring=[b]",
  keywordstyle=\bfseries,
  ndkeywordstyle=\bfseries,
  identifierstyle=\color{black},
  commentstyle=\ttfamily,
  stringstyle=\ttfamily,
  sensitive=true
}

\newcommand\codecpp{\lstset{language=C++,
breaklines=true,
extendedchars=true,
literate={ä}{{\"a}}1 {ö}{{\"o}}1 {ü}{{\"u}}1 {é}{{\'e}}1 {—}{{-}}1
  {continue}{\textbf{$\circlearrowleft{}$continue{}}}{10}
  {return\ }{\textbf{$\hookleftarrow{}$return {}}}{8}
  {throw\ }{\textbf{$\Uparrow{}$throw {}}}{7}
  {=}{$\overset{\operatorname{def}}{=}{}$}{1}
  {==}{$\overset{?}{==}{}$\quad}{2}
  {+=}{$\overset{\nearrow}{+=}{}$}{2}
  {-=}{$\overset{\searrow}{-=}{}$}{2}
  {->}{$\rightarrow{}$}{1}
  {>>}{$\gg{}$}{2}
  {<<}{$\ll{}$}{2}
  {>=}{$\ge{}$}{2}
  {<=}{$\le{}$}{2}
  {::}{$::$}{1}
  {!=}{${}\ne{}$}{1}
  {++}{$\overset{\nearrow}{++}{}$}{1}
  {--}{$\overset{\searrow}{--}{}$}{1}
  {*}{$\ast{}$\quad}{1},
}}
\newcommand\codecmake{\lstset{language=CMake,breaklines=true}}
\newcommand\codebisonflex{\lstset{language=bisonflex,breaklines=true}}
\newcommand\codepython{\lstset{language=Python,breaklines=true}}

\newcounter{todobugcounter}
\newcommand{\todobug}[1]{\stepcounter{todobugcounter}\todo[color=red!60]{Bug \thetodobugcounter: #1}}
\newcounter{todoremovecounter}
\newcommand{\todoremove}[1]{\stepcounter{todoremovecounter}\todo[color=red!40]{Remove \thetodoremovecounter: #1}}
\newcounter{todorefactorcounter}
\newcommand{\todorefactor}[1]{\stepcounter{todorefactorcounter}\todo[color=yellow!40]{Refactor \thetodorefactorcounter: #1}}
\newcounter{todoimplementcounter}
\newcommand{\todoimplement}[1]{\stepcounter{todoimplementcounter}\todo[color=blue!40]{Implement \thetodoimplementcounter: #1}}
\newcounter{tododocumentcounter}
\newcommand{\tododocument}[1]{\stepcounter{tododocumentcounter}\todo[color=green!40]{Document \thetododocumentcounter: #1}}

% This is to fix filePositioning of todo comments on the left margin:
\setlength{\marginparwidth}{2.7cm}

\usetikzlibrary{shapes,arrows,chains,decorations.pathmorphing,calc}
\pgfdeclarelayer{bg}
\pgfsetlayers{bg,main}
\newcommand{\tikzflowchart}{\tikzset{
  base/.style={draw, on chain, on grid, align=center, minimum height=4ex},
  proc/.style={base, rectangle},
  test/.style={base, diamond, aspect=2},
  term/.style={proc, rounded corners},
  emit/.style={proc, rounded corners, double, double distance=1mm},
  wait/.style={base, trapezium, trapezium left angle=120, trapezium right angle=60},
  var/.style={base, rectangle split, rectangle split parts=2, rounded corners},
  coord/.style={coordinate, on chain, on grid, node distance=6mm and 25mm},
  nmark/.style={draw, cyan, circle, font={\sffamily\bfseries}},
  norm/.style={->, draw},
  sig/.style={->, decorate, decoration={snake}, draw},
  class/.style={dashed, draw},
  indirect/.style={dotted, draw,-},
  it/.style={font={\small\itshape}},
  >=triangle 60,
  start chain=going below,
  node distance=6mm and 50mm,
  every join/.style={norm}
}}

\setcounter{secnumdepth}{5}
\setcounter{tocdepth}{5}

\newcommand{\doubleLinkedIndexEntry}[2]{\index{#1@@\textbf{#1}!#2@@\textsl{#2}}\index{#2@@\textsl{#2}!#1}}
\newcommand{\indexHeader}[1]{\index{Header@@\textbf{Header}!#1@@\textsl{#1}}\codecpp}
\newcommand{\indexBackusNaur}[1]{\doubleLinkedIndexEntry{Backus-Naur form}{#1}}
\newcommand{\indexBisonRule}[1]{\doubleLinkedIndexEntry{Bison rule}{#1}\codebisonflex}
\newcommand{\indexClass}[1]{\doubleLinkedIndexEntry{Class definition}{#1}\codecpp}
\newcommand{\indexClassBaseOf}[2]{\index{#2@@\textsl{#2}!Base class #1@@Base class \textsl{#1}}\codecpp}
\newcommand{\indexClassMethod}[2]{\index{#1@@\textsl{#1}!Methods!#2@@\textsl{#2}}\index{#1::#2@@\textsl{#1::#2}}}
\newcommand{\indexStructure}[1]{\doubleLinkedIndexEntry{Structure definition}{#1}\codecpp}
\newcommand{\indexFlexRule}[1]{\doubleLinkedIndexEntry{Flex rule}{#1}\codebisonflex}
\newcommand{\indexBisonType}[1]{\doubleLinkedIndexEntry{Bison type}{#1}\codebisonflex}
\newcommand{\indexBisonRuleUsesToken}[2]{\index{#2@@\textsl{#2}!Bison rules!#1@@\textsl{#1}}\index{#1@@\textsl{#1}!Terminals!#2@@\textsl{#2}}\codebisonflex}
\newcommand{\classDeclaration}[1]{Declaration of \normalfont``\codecpp{\lstinline{class #1}}''}
\newcommand{\classImplementation}[1]{Implementation of \normalfont``\codecpp{\lstinline{class #1}}''}
\newcommand{\functionPartImplementation}[1]{{\normalfont\codecpp{\lstinline{#1}(...)}}}
\newcommand{\staticDefinitions}[1]{Static definitions for \normalfont``\codecpp{\lstinline{class #1}}''}
\newcommand{\bisonRule}[1]{Bison rule for \normalfont``\codebisonflex{\lstinline{#1}}''}
\newcommand{\bisonTypeDefinition}[1]{Bison type definition for \normalfont``\codebisonflex{\lstinline{#1}}''}
