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

\section{Class scrapStandalone}
\subsection{Interface}
@d \classDeclaration{scrapStandalone}
@{@%
class scrapStandalone : public scrap {
private:
    
public:
    scrapStandalone(documentPart&& l_documentPart);
    virtual std::string texUtf8(void) const override;
    virtual void resolveReferences(void) override;
};
@| scrapStandalone @}

\subsubsection{scrapStandalone}
\indexClassMethod{scrapStandalone}{scrapStandalone}
@d \classImplementation{scrapStandalone}
@{@%
     nuweb::scrapStandalone::scrapStandalone(documentPart&& l_documentPart) : scrap(std::move(l_documentPart)){
        
    }
@| scrapStandalone @}

\subsubsection{texUtf8}
\indexClassMethod{scrapStandalone}{texUtf8}
@d \classImplementation{scrapStandalone}
@{@%
    std::string nuweb::scrapStandalone::texUtf8(void) const{
        return scrap::texUtf8();
    }
@| texUtf8 @}
\subsubsection{resolveReferences}
\indexClassMethod{scrapStandalone}{resolveReferences}
@d \classImplementation{scrapStandalone}
@{@%
    void nuweb::scrapStandalone::resolveReferences(void){
        if(!empty())
            for(auto& scrapPart: *this){
                fragmentReference* possibleFragmentReference = dynamic_cast<fragmentReference*>(scrapPart);
                if(possibleFragmentReference)
                    possibleFragmentReference->setOutsideFragment(true);
                scrapPart->resolveReferences();
            }
    }
@| resolveReferences @}
