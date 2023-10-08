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

\section{Class crossReference}
\subsection{Interface}
\indexClass{crossReference}
@d \classDeclaration{crossReference}
@{@%
class crossReference : public documentPart {
private:
    unsigned int m_scrapNumber; 
    static std::map<unsigned int, unsigned int> m_numberOfReferencesForScrap;
    static std::map<std::string, std::string> m_refToScrapString;
    unsigned int m_referenceNumber;
public:
    crossReference(filePosition* l_filePosition);
    virtual std::string utf8(filePosition& l_filePosition) const override;
    virtual std::string texUtf8(void) const override;
    void setScrapNumber(unsigned int scrapNumber);
};
@| crossReference @}

@d \staticDefinitions{crossReference}
@{@%
    std::map<unsigned int, unsigned int> nuweb::crossReference::m_numberOfReferencesForScrap = {};
    std::map<std::string, std::string> nuweb::crossReference::m_refToScrapString = {};
@}

\subsubsection{crossReference}
\indexClassMethod{crossReference}{crossReference}
@d \classImplementation{crossReference}
@{@%
     nuweb::crossReference::crossReference(filePosition* l_filePosition) : documentPart(l_filePosition), m_scrapNumber(0), m_referenceNumber(0) {
        
    }
@| crossReference @}

\subsubsection{texUtf8}
\indexClassMethod{crossReference}{texUtf8}
@d \classImplementation{crossReference}
@{@%
    std::string nuweb::crossReference::texUtf8(void) const{
        filePosition ll_filePosition("",1,documentPart::m_fileIndentation+1,1,1);
        return utf8(ll_filePosition);
    }
@| texUtf8 @}

\subsubsection{utf8}
\indexClassMethod{crossReference}{utf8}
@d \classImplementation{crossReference}
@{@%
    std::string nuweb::crossReference::utf8(filePosition& l_filePosition) const{
        if(m_scrapNumber==0)
            return m_refToScrapString[documentPart::utf8(l_filePosition)];
        else
            return std::to_string(m_scrapNumber) + "-" + (m_referenceNumber < 10 ? "0" : "") + std::to_string(m_referenceNumber);
    }
@| utf8 @}
\subsubsection{setScrapNumber}
\indexClassMethod{crossReference}{setScrapNumber}
@d \classImplementation{crossReference}
@{@%
    void nuweb::crossReference::setScrapNumber(unsigned int scrapNumber){
        m_scrapNumber = scrapNumber;
        m_numberOfReferencesForScrap[m_scrapNumber]++;
        m_referenceNumber = m_numberOfReferencesForScrap[m_scrapNumber];
        std::string scrapString = std::to_string(m_scrapNumber) + "-" + (m_referenceNumber < 10 ? "0" : "") + std::to_string(m_referenceNumber);
        filePosition ll_filePosition("",1,documentPart::m_fileIndentation+1,1,1);
        m_refToScrapString[documentPart::utf8(ll_filePosition)] = scrapString;
    }
@| setScrapNumber @}
