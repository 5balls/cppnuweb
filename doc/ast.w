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

\chapter{Abstract Syntax Tree Classes}
We define some classes for our Abstract Syntax Tree. This correspond mostly to the non terminal expressions in the Bison grammar and are used there to build up the tree.

@i ast_definitions.w

@i ast_document.w

@i ast_documentpart.w

@i ast_fragmentdefinition.w

@i ast_fragmentquoted.w

@i ast_fragmentreference.w

@i ast_fragmentnamepartdefinition.w

@i ast_fragmentnameparttext.w

@i ast_fragmentnamepartargument.w

@i ast_fragmentnamepartargumentstring.w

@i ast_fragmentnamepartargumentfragmentname.w

@i ast_scrapverbatimargument.w

@i ast_outputfile.w

@i ast_scrap.w

@i ast_scrapverbatim.w

@i ast_scrapstandalone.w

@i ast_fragmentargument.w

@i ast_useridentifiers.w

@i ast_index_fragmentnames.w

@i ast_versionstring.w

@i ast_crossreference.w

@i ast_blockcomment.w

@i ast_blockcommentreference.w

@i ast_currentfile.w
