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

\subsection{Test fragmentArgumentString}
\index{fragment}{fragmentArgumentString}This is the first of four type of arguments which can be passed to a fragment. The string is just copied literally to the output.
@o ../tests/test_fragmentArgumentString.w
@{@<Start of simple \LaTeX{} document@>@@d Fragment @@'argument@@'
@@{@<Lorem ipsum@>@@1@@}
@<End of simple \LaTeX{} document@>
@}

@o ../tests/test_expected_fragmentArgumentString.tex
@{@<Nuweb \LaTeX{} definitions@>@<Start of simple \LaTeX{} document@>\begin{flushleft} \small
\begin{minipage}{\linewidth}\label{scrap1}\raggedright\small
\NWtarget{nuweb1}{} $\langle\,${\itshape Fragment \hbox{\slshape\sffamily argument\/}}\nobreak\ {\footnotesize {1}}$\,\rangle\equiv$
\vspace{-1ex}
\begin{list}{}{} \item
\mbox{}\verb@@@<Lorem ipsum@>@@\hbox{\slshape\sffamily argument\/}\verb@@@@{\NWsep}
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
@{@<nuweb comparison for test @'fragmentArgumentString@' with expected output and \LaTeX{} run@>
@}

\subsection{Test fragmentArgumentStringExpansion}
\index{fragment}{fragmentArgumentStringExpansion}
@o ../tests/test_fragmentArgumentStringExpansion.w
@{@<Start of simple \LaTeX{} document@>@@d Fragment @@'argument@@'
@@{@<Lorem ipsum@>@@1@@}
@@<Fragment @@'Expanded argument@@'@@>
@<End of simple \LaTeX{} document@>
@}

@o ../tests/test_expected_fragmentArgumentStringExpansion.tex
@{@<Nuweb \LaTeX{} definitions@>@<Start of simple \LaTeX{} document@>\begin{flushleft} \small
\begin{minipage}{\linewidth}\label{scrap1}\raggedright\small
\NWtarget{nuweb1}{} $\langle\,${\itshape Fragment \hbox{\slshape\sffamily argument\/}}\nobreak\ {\footnotesize {1}}$\,\rangle\equiv$
\vspace{-1ex}
\begin{list}{}{} \item
\mbox{}\verb@@@<Lorem ipsum@>@@\hbox{\slshape\sffamily argument\/}\verb@@@@{\NWsep}
\end{list}
\vspace{-1.5ex}
\footnotesize
\begin{list}{}{\setlength{\itemsep}{-\parsep}\setlength{\itemindent}{-\leftmargin}}
\item {\NWtxtMacroNoRef}.

\item{}
\end{list}
\end{minipage}\vspace{4ex}
\end{flushleft}
@<Lorem ipsum@>Expanded argument
@<End of simple \LaTeX{} document@>
@}
@d nuweb unit test functions
@{@<nuweb comparison for test @'fragmentArgumentStringExpansion@' with expected output and \LaTeX{} run@>
@}

\subsection{Test fragmentArgumentStringExpansionInOtherFragment}
\index{fragment}{fragmentArgumentStringExpansionInOtherFragment}
@o ../tests/test_fragmentArgumentStringExpansionInOtherFragment.w
@{@<Start of simple \LaTeX{} document@>@@d Fragment @@'argument@@'
@@{@<Lorem ipsum@>@@1@@}
@@d Second fragment
@@{@@<Fragment @@'Expanded argument@@'@@>@@}
@<End of simple \LaTeX{} document@>
@}

@o ../tests/test_expected_fragmentArgumentStringExpansionInOtherFragment.tex
@{@<Nuweb \LaTeX{} definitions@>@<Start of simple \LaTeX{} document@>\begin{flushleft} \small
\begin{minipage}{\linewidth}\label{scrap1}\raggedright\small
\NWtarget{nuweb1a}{} $\langle\,${\itshape Fragment \hbox{\slshape\sffamily argument\/}}\nobreak\ {\footnotesize {1a}}$\,\rangle\equiv$
\vspace{-1ex}
\begin{list}{}{} \item
\mbox{}\verb@@@<Lorem ipsum@>@@\hbox{\slshape\sffamily argument\/}\verb@@@@{\NWsep}
\end{list}
\vspace{-1.5ex}
\footnotesize
\begin{list}{}{\setlength{\itemsep}{-\parsep}\setlength{\itemindent}{-\leftmargin}}
\item \NWtxtMacroRefIn\ \NWlink{nuweb1b}{1b}.

\item{}
\end{list}
\end{minipage}\vspace{4ex}
\end{flushleft}
\begin{flushleft} \small
\begin{minipage}{\linewidth}\label{scrap2}\raggedright\small
\NWtarget{nuweb1b}{} $\langle\,${\itshape Second fragment}\nobreak\ {\footnotesize {1b}}$\,\rangle\equiv$
\vspace{-1ex}
\begin{list}{}{} \item
\mbox{}\verb@@@@\hbox{$\langle\,${\itshape Fragment \verb@@Expanded argument@@}\nobreak\ {\footnotesize \NWlink{nuweb1a}{1a}}$\,\rangle$}\verb@@@@{\NWsep}
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
@{@<nuweb comparison for test @'fragmentArgumentStringExpansionInOtherFragment@' with expected output and \LaTeX{} run@>
@}
