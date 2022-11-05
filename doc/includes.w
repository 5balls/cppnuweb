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

\documentclass[a4paper]{book}
\usepackage{listings}
\usepackage{imakeidx}
\usepackage[margin=2cm]{geometry}
\usepackage{longtable}
\usepackage{verbatim}
\usepackage{pgf-umlsd}
\usepackage{tikz}
\usepackage[textsize=tiny, textwidth=2.7cm, colorinlistoftodos]{todonotes}
\usepackage{etoolbox}% http://ctan.org/pkg/etoolbox
\usepackage{syntax} 
\usepackage{amssymb}
\usepackage{amsmath}
\usepackage{bigfoot}
\setlength{\grammarparsep}{10pt} % increase separation between rules
\setlength{\grammarindent}{12em} % increase separation between LHS/RHS 

\makeatletter
\patchcmd{\@@makechapterhead}{\vspace*{50\p@@}}{}{}{}% Removes space above \chapter head
\patchcmd{\@@makeschapterhead}{\vspace*{50\p@@}}{}{}{}% Removes space above \chapter* head
\makeatother
\usepackage[colorlinks=true]{hyperref}
% The following fixes a bigfoot bug that makes the footnotes appear on an page
% earlier than the reference
% Fix found at
% https://tex.stackexchange.com/questions/471379/footnote-marks-missplaced-with-bigfoot/472710#472710
\usepackage{xpatch}
\makeatletter
\patchcmd\FN@@allmarks{266}{256}{}{\fail}
\makeatother
\makeindex[options=-s ./index]
\usepackage{tocbibind}
