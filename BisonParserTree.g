/* ANTLR generated tree grammar for bison parser
 
[The "BSD licence"]
 Copyright (c) 2005 Terence Parr
 All rights reserved.

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



header {
import java.io.*;
import antlr.collections.AST;
}

class BisonParserTree extends TreeParser;

options {
	importVocab = Bison;
	buildAST = false;
}

{	private int indent = 0;
	private int altLevel = 0;
	private FileOutputStream _out = null;
	private PrintStream p = null;
	private File file = null;
	protected String path = null;
	protected String name = null;

	public void setPath(String path_) {
		path = path_;
	}

	public void setFileName(String name_) {
		name = name_;
	}


	protected void println(String s) {
		int i;
		String str = new String();

		for (i=0; i<indent; i++) {
			str += "\t";
		}
		p.println(str + s);
	}

	protected void printStringln(String s) {
		int i;
		String str = new String();

		for (i=0; i<indent; i++) {
			str += "\t";
		}
		p.print(str);
		p.print('\"');
		p.print(s);
		p.println('\"');
	}
		

	protected void initOut(String name_) {
		if (name_ == null)
			name_ = name;
		int end = name_.lastIndexOf('.');
		String outFile = name_.substring(0, end) + ".g";
		try {
			if (path != null) {
				file = new File(path, outFile);
				_out = new FileOutputStream(file);
			}
			else
				_out = new FileOutputStream(outFile);
		}
		catch (FileNotFoundException e) {
			System.out.println("file not found");
			System.exit(1);
		}
		catch (IOException ie) {
			System.out.println("I/O exception");
			System.exit(1);
		}
		p = new PrintStream(_out);
		printHeader();

		// Add options for class and file names
		p.println("class " + name + " extends Parser;");
		p.println("options {");
		p.println("}");
		p.println("");
	}

	protected void printHeader() {
		p.println("// ANTLR translated grammar");
		p.println("\n\n\n");
		p.println("header {");
		p.println("}");
		p.println("");
	}

}


grammar
	:
	{ initOut(null); }
	(
		c:COMMENT { p.println(#c.getText()); }
	|
		rule
	)+
	;

rule
	:
	#( 
		i:ID	{ p.println(#i.getText() + "\n\t:"); indent++; }
		rhs
		{ p.println("\t;\n\n"); indent--; }
	)
	;

rhs
	:
	#( 
		OR
		rhs
		{	println("|");
			indent++;
			altLevel++;
		}
		rhs_alt
		{ altLevel--; indent--; }
	)
	|
		#( ALT rhs_alt )
	;

rhs_alt
	:
	(
		rhs_element
	)*
	;

rhs_element
	:
	symbol
	|	c:COMMENT { println(#c.getText()); }
	;

symbol
	:
	i:ID	{ println(#i.getText()); }
	|
		s:STRING	{ printStringln(#s.getText()); }
	;

