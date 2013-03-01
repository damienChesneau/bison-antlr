/* Main class for translating Python Grammars to ANTLR 
 */


import java.io.*;
import antlr.collections.AST;
import antlr.collections.impl.*;
import antlr.debug.misc.*;
import antlr.*;
import java.awt.event.*;

class BisonReader {

	public static void main(String[] args) {
		String path = null;
		File file = null;
	    
		// Use a try/catch block for parser exceptions
		try {
			// if we have at least one command-line argument
			if (args.length > 0 ) {
				System.err.println("Parsing...");
				// for each directory/file specified on the command line
				for(int i=0; i< args.length;i++) {
					if ( args[i].equals("-o") ) {
						i++;
						path = args[i];
					}
					else { // file name
						file = new File(args[i]);
					}
				}
				doFile(file, path);
			}
			else {
				System.err.println("Usage: java BisonReader" +
					" [-o directory] " +
					"<file name>");
			}
		}
		catch(Exception e) {
			System.err.println("exception: "+e);
			e.printStackTrace(System.err);   // so we can get stack trace
		}
	}

	// This method decides what action to take based on the type of
	//   file we are looking at
	public static void doFile(File f, String path)
							  throws Exception {
		System.err.println("   "+f.getAbsolutePath());
		// parseFile(f.getName(), new FileInputStream(f));
		parseFile(f.getName(), new BufferedReader(new FileReader(f)), path);
	}

	// Here's where we do the real work...
	public static void parseFile(String f, Reader r, String path)
			throws Exception {
		try {
			// Create a scanner that reads from the input stream passed to us
			BisonLexer lexer = new BisonLexer(r);
			lexer.setFilename(f);

			// Create a parser that reads from the scanner
			BisonParser parser = new BisonParser(lexer);
			parser.setFilename(f);

			// start parsing at the compilationUnit rule
			parser.input();
			
			// do something with the tree
			doTreeAction(f, parser.getAST(), path);
		}
		catch (Exception e) {
			System.err.println("parser exception: "+e);
			e.printStackTrace();   // so we can get stack trace		
		}
	}
	
	public static void doTreeAction(String f, AST t, String path) {
		if ( t==null )
			return;
		
		BisonParserTree tparse = new BisonParserTree();
		tparse.setFileName(f);
		tparse.setPath(path);
		try {
			tparse.grammar(t);
		}
		catch (RecognitionException e) {
			System.err.println(e.getMessage());
			e.printStackTrace();
		}

	}
}

