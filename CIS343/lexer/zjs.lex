
%{
    #include <stdio.h>
%}

%option noyywrap
%%

end             { printf("END\n"); }
;               { printf("END_STATEMENT\n"); }
line            { printf("LINE\n"); }
point           { printf("POINT\n"); }
circle          { printf("CIRCLE\n"); }
rectangle       { printf("RECTANGLE\n"); }
set_color       { printf("SET_COLOR\n"); }
[0-9]+          { printf("INTEGER\n"); }
[0-9]+\.[0-9]+  { printf("FLOATING POINT\n"); }
[' '\t\n]       ;
.               { printf("This is wrong: %s\n", yytext); }

%%

int main(int argc, char** argv) {
  yylex();
}
