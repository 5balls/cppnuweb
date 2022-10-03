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

@i parser_lexical_analysis.w

\section{Context free grammar}

The context free grammar is defined by a Bison file. We use the C++ code generator of Bison as well as the C++ code generator for Flex which leads to some extra work.

@O ../src/nuweb.y
@{

%require "3.2"
%language "c++"

@<Bison parse parameters first@>
@<Bison parse parameters@>
@<Bison flex parameters@>
@}

@i parser_glue_code.w

@i parser_tokens.w

\subsection{Rules}

The following rules are used to create the parser for nuweb. They also define a grammar for nuweb files in Backus-Naur form. 

@O ../src/nuweb.y
@{
%%
 /* rules */
@<Bison rules@>
%%
 /* code */
@}

