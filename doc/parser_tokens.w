\subsection{Tokens and types}

\codebisonflex
@O ../src/nuweb.y
@{

%token TEX_WITHOUT_AT
%token FILENAME
%token AT_CURLY_BRACKET_OPEN AT_CURLY_BRACKET_CLOSE AT_SQUARE_BRACKET_OPEN AT_SQUARE_BRACKET_CLOSE AT_ROUND_BRACKET_OPEN AT_ROUND_BRACKET_CLOSE AT_ANGLE_BRACKET_OPEN AT_ANGLE_BRACKET_CLOSE AT_ANGLE_BRACKET_OPEN_PLUS 
%token AT_I AT_AT AT_UNDERLINE AT_TICK AT_NUMBER AT_X AT_T AT_HASH AT_S AT_PERCENT AT_V AT_M AT_M_PLUS AT_U
%token AT_PIPE AT_MINUS AT_PLUS AT_U_PLUS
%token FLAG_D FLAG_I FLAG_T FLAG_C_C FLAG_C_PLUS FLAG_C_P
%token AT_SMALL_O AT_LARGE_O AT_SMALL_D AT_LARGE_D AT_SMALL_Q AT_LARGE_Q AT_SMALL_F AT_LARGE_F AT_LARGE_D_PLUS AT_SMALL_D_PLUS AT_LARGE_Q_PLUS AT_SMALL_S AT_SMALL_Q_PLUS AT_LARGE_S

%union
{
    int m_int;
    std::string* m_string;
    nuwebPosition* m_position;
    nuwebPositionWithInt* m_intValue;
    nuwebPositionWithString* m_stringValue;
    nuwebDocument* m_nuwebDocument;
    nuwebElement* m_nuwebElement;
}

%type <m_nuwebDocument> nuwebDocument;
%type <m_nuwebElement> nuwebElement;
%type <m_stringValue> TEX_WITHOUT_AT;

@}
