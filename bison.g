/* Extended Bison Grammar Parser

 [The "BSD licence"]
 Copyright (c) 2006 Loring Craymer


 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 1. Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
 3. The name of the author may not be used to endorse or promote products
    derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/



class BisonParser extends Parser;

options {
	exportVocab=Bison;
	buildAST = true;
	defaultErrorHandler=true;
	k=2;
}

tokens {
	PERCENT_TOKEN       = "%token";
	PERCENT_NTERM       = "%nterm";

	PERCENT_TYPE        = "%type";
	PERCENT_DESTRUCTOR  = "%destructor";
	PERCENT_PRINTER     = "%printer";

	PERCENT_UNION       = "%union";

	PERCENT_LEFT        = "%left";
	PERCENT_RIGHT       = "%right";
	PERCENT_NONASSOC    = "%nonassoc";

	PERCENT_PREC          = "%prec";
	PERCENT_DPREC         = "%dprec";
	PERCENT_MERGE         = "%merge";

	PERCENT_DEBUG           = "%debug";
	PERCENT_DEFAULT_PREC    = "%default-prec";
	PERCENT_DEFINE          = "%define";
	PERCENT_DEFINES         = "%defines";
	PERCENT_ERROR_VERBOSE   = "%error-verbose";
	PERCENT_EXPECT          = "%expect";
	PERCENT_EXPECT_RR	  = "%expect-rr";
	PERCENT_FILE_PREFIX     = "%file-prefix";
	PERCENT_GLR_PARSER      = "%glr-parser";
	PERCENT_INITIAL_ACTION  = "%initial-action";
	PERCENT_LEX_PARAM       = "%lex-param";
	PERCENT_LOCATIONS       = "%locations";
	PERCENT_NAME_PREFIX     = "%name-prefix";
	PERCENT_NO_DEFAULT_PREC = "%no-default-prec";
	PERCENT_NO_LINES        = "%no-lines";
	PERCENT_NONDETERMINISTIC_PARSER = "%nondeterministic-parser";
	PERCENT_OUTPUT          = "%output";
	PERCENT_PARSE_PARAM     = "%parse-param";
	PERCENT_PURE_PARSER     = "%pure_parser";
	PERCENT_REQUIRE	  = "%require";
	PERCENT_SKELETON        = "%skeleton";
	PERCENT_START           = "%start";
	PERCENT_TOKEN_TABLE     = "%token-table";
	PERCENT_VERBOSE         = "%verbose";
	PERCENT_YACC            = "%yacc";
	ALT;
}



input
	:
	( COMMENT | declaration! )*
	PERCENT_PERCENT! grammar epilogue_dot_opt!
	;



declaration!
	:
	grammar_declaration
	|	PROLOGUE                                 
	|	"%debug"                              
	|	"%define" STRING /* content */ ( STRING /* content */ )?  
	|	"%defines"                               
	|	"%error-verbose"                         
	|	"%expect" INT                            
	|	"%expect-rr" INT			   
	|	"%file-prefix" "=" STRING /* content */        
	|	"%glr-parser"
	|	"%initial-action" ACTION
	|	"%lex-param" ACTION
	|	"%locations"                             
	|	"%name-prefix" "=" STRING /* content */        
	|	"%no-lines"                              
	|	"%nondeterministic-parser"		   
	|	"%output" "=" STRING /* content */             
	|	"%parse-param"	ACTION
	|	"%pure_parser"                         
	|	"%require" STRING /* content */               
	|	"%skeleton" STRING /* content */               
	|	"%token-table"                           
	|	"%verbose"                               
	|	"%yacc"                                  
	;

grammar_declaration!
	:
	precedence_declaration
	|	symbol_declaration
	|	"%start" symbol
	|	"%union" ACTION
	|	"%destructor" ACTION ( symbol )+
	|	"%printer" ACTION ( symbol )+
	|	"%default-prec"
	|	"%no-default-prec"
	;

symbol_declaration!
	:
	"%nterm" ( symbol_def )+
	|	"%token" ( symbol_def )+
	|	"%type" TYPE ( symbol )+
	;

precedence_declaration
	:
	precedence_declarator ( TYPE )?  ( symbol )+
	;

precedence_declarator
	:
	"%left"     
	|	"%right"    
	|	"%nonassoc" 
	;


/* One token definition.  */
symbol_def
	:
	TYPE
	|	ID
		(	INT (STRING)?
		|	STRING
		)?
	;



	/*------------------------------------------.
	| The grammar section: between the two %%.  |
	`------------------------------------------*/

grammar
	:
/* As a Bison extension, one can use the grammar declarations in the
   body of the grammar.  */
	(	rule
	|!	grammar_declaration SEMI
	)+
	;

rule
	:
	ID^ COLON! rhs
	( SEMI! )?
	;


rhs
	:
	rhs_alt 
	{ ## = #( [ALT, "alt"], #rhs ); }
	( OR^ rhs_alt )*
	;

rhs_alt
	:
	( rhs_element )*
	;

rhs_element
	:
	symbol
	|	a:ACTION!	// fix this later--actions should be optionally inserted
	|	("%prec" symbol)!
	|	("%dprec" INT)!
	|	("%merge" TYPE)!
	|	e:"error" { #e.setType(ID); }	// error handlers
	|	COMMENT
	;

symbol
	:
	ID             
	|	STRING   
	;


epilogue_dot_opt
	:
	( EPILOGUE )?
	;




class BisonLexer extends Lexer;
options {
	k=2;
	exportVocab=Bison;
	testLiterals=false;
	interactive=true;
	charVocabulary='\003'..'\377';
}


{
	private int section = 0;

	/**Convert 'c' to an integer char value. */
	public static int escapeCharValue(String cs) {
		//System.out.println("escapeCharValue("+cs+")");
		if ( cs.charAt(1)!='\\' ) return 0;
		switch ( cs.charAt(2) ) {
		case 'b' : return '\b';
		case 'r' : return '\r';
		case 't' : return '\t';
		case 'n' : return '\n';
		case 'f' : return '\f';
		case '"' : return '\"';
		case '\'' :return '\'';
		case '\\' :return '\\';

		case 'u' :
			// Unicode char
			if (cs.length() != 8) {
				return 0;
			}
			else {
				return
					Character.digit(cs.charAt(3), 16) * 16 * 16 * 16 +
					Character.digit(cs.charAt(4), 16) * 16 * 16 +
					Character.digit(cs.charAt(5), 16) * 16 +
					Character.digit(cs.charAt(6), 16);
			}

		case '0' :
		case '1' :
		case '2' :
		case '3' :
			if ( cs.length()>5 && Character.isDigit(cs.charAt(4)) ) {
				return (cs.charAt(2)-'0')*8*8 + (cs.charAt(3)-'0')*8 + (cs.charAt(4)-'0');
			}
			if ( cs.length()>4 && Character.isDigit(cs.charAt(3)) ) {
				return (cs.charAt(2)-'0')*8 + (cs.charAt(3)-'0');
			}
			return cs.charAt(2)-'0';

		case '4' :
		case '5' :
		case '6' :
		case '7' :
			if ( cs.length()>4 && Character.isDigit(cs.charAt(3)) ) {
				return (cs.charAt(2)-'0')*8 + (cs.charAt(3)-'0');
			}
			return cs.charAt(2)-'0';

		default :
			return 0;
		}
	}

	public static int tokenTypeForCharLiteral(String lit) {
		if ( lit.length()>3 ) {  // does char contain escape?
			return escapeCharValue(lit);
		}
		else {
			return lit.charAt(1);
		}
	}
}

WS	:	(	/*	'\r' '\n' can be matched in one alternative or by matching
				'\r' in one iteration and '\n' in another.  I am trying to
				handle any flavor of newline that comes in, but the language
				that allows both "\r\n" and "\r" and "\n" to all be valid
				newline is ambiguous.  Consequently, the resulting grammar
				must be ambiguous.  I'm shutting this warning off.
			 */
			options {
				generateAmbigWarnings=false;
			}
		:	' '
		|	'\t'
		|	'\r' '\n'	{newline();}
		|	'\r'		{newline();}
		|	'\n'		{newline();}
		)
		{ $setType(Token.SKIP); }
	;

protected
PERCENT_PERCENT : ;

protected
EPILOGUE : ;

protected
PROLOGUE : ;

protected
DOC_COMMENT : ;

COMMENT :
	"/*"
//	(	{ LA(2)!='/' }? '*' {$setType(DOC_COMMENT);}
//	|
//	)
	(
		/*	'\r' '\n' can be matched in one alternative or by matching
			'\r' and then in the next token.  The language
			that allows both "\r\n" and "\r" and "\n" to all be valid
			newline is ambiguous.  Consequently, the resulting grammar
			must be ambiguous.  I'm shutting this warning off.
		 */
		options {
			greedy=false;  // make it exit upon "*/"
			generateAmbigWarnings=false; // shut off newline errors
		}
	:	'\r' '\n'	{newline();}
	|	'\r'		{newline();}
	|	'\n'		{newline();}
	|	~('\n'|'\r')
	)*
	"*/"
	;

TYPE
	:
	'<' ( ~('.'|'>'))+ '>'
	;

COLON :	':' ;

ASSIGN : '=' ;

SEMI:	';' ;

OR	:	'|' ;

CHAR_LITERAL
	:	'\''! (ESC|~'\'') '\''!
		{	String txt = $getText;
			$setText( '"' + txt + '"');
			$setType(ID);
		}
	;

STRING
	:	'"' (ESC|~'"')* '"'
	;

protected
ESC	:	'\\'
		(	'n'
		|	'r'
		|	't'
		|	'b'
		|	'f'
		|	'w'
		|	'a'
		|	'"'
		|	'\''
		|	'\\'
		|	('0'..'3')
			(
				options {
					warnWhenFollowAmbig = false;
				}
			:
	('0'..'9')
				(
					options {
						warnWhenFollowAmbig = false;
					}
				:
	'0'..'9'
				)?
			)?
		|	('4'..'7')
			(
				options {
					warnWhenFollowAmbig = false;
				}
			:
	('0'..'9')
			)?
		|	'u' XDIGIT XDIGIT XDIGIT XDIGIT
		)
	;

protected
DIGIT
	:	'0'..'9'
	;

protected
XDIGIT :
		'0' .. '9'
	|	'a' .. 'f'
	|	'A' .. 'F'
	;


INT	:	('0'..'9')+
	;

ACTION
{int actionLine=getLine(); int actionColumn = getColumn(); }
	:	NESTED_ACTION
		{
			CommonToken t = new CommonToken(_ttype,$getText);
			t.setLine(actionLine);			// set action line to start
			t.setColumn(actionColumn);
			$setToken(t);
		}
	;

protected
NESTED_ACTION :
	'{'
	(
		options {
			greedy = false; // exit upon '}'
		}
	:
		(
			options {
				generateAmbigWarnings = false; // shut off newline warning
			}
		:	'\r' '\n'	{newline();}
		|	'\r' 		{newline();}
		|	'\n'		{newline();}
		)
	|	NESTED_ACTION
	|	CHAR_LITERAL
	|	COMMENT
	|	STRING
	|	.
	)*
	'}'
   ;

protected
LETTER
	:
	'a' .. 'z'
	|	'A' .. 'Z' 
	|	'.' 
	|	'_'
	;

protected
IDENTIFIER
	:
	LETTER ( LETTER | DIGIT )*
	;

ID
options {
	testLiterals=true;
}
	:
	IDENTIFIER
	;


KEYWORD
options {
	testLiterals=true;
}
	:
	'%'
	(	IDENTIFIER
	|	'%'
		(	{ section == 0 }? { section++; $setType(PERCENT_PERCENT); }
		|	( . )* { $setType(EPILOGUE); section++; }
		)
	|	'{'  	(	~ ('\\' | '%' )
			|	'\\' .
			|	'%' ~('}')
			)*
		'%' '}' { $setType(PROLOGUE); }
	)
	;


protected
WS_LOOP
	:	(	// grab as much WS as you can
			options {
				greedy=true;
			}
		:
			WS
		|	COMMENT
		)*
	;

