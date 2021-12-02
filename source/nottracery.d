module nottracery;

import std.stdio;
import std.conv;
import std.string;
import std.json;
import std.random;
import std.exception;

@safe:

class Grammar
{
	Symbol[string] symbols;

	this(JSONValue jsonValue)
	{
		enforce(jsonValue.type == JSONType.object, "input must be valid json");
		foreach (key, value; jsonValue.objectNoRef)
		{
			symbols[key] = new Symbol(value, this);
		}
	}

	string createFlattened(string symbolID = "origin")
	{
		//auto trace = new Trace(symbolID);

		char[] result;
		size_t num = uniform(0, this.symbols[symbolID].rules.length);

		foreach (value; this.symbols[symbolID].rules[num].tokens)
		{
			if (value.isLiteral)
			{
				result ~= value.data;
			} else {
				result ~= createFlattened(value.data);
			}
		}

		return result.idup;
	}

	/*Trace createTrace(string tracestring)
	{
		return "";
	}

	Trace createTraceFromSymbol(Symbol symbol)
	{
		return "";
	}*/

}

class Symbol
{
	Rule[] rules;
	Grammar parent;

	this(JSONValue jsonValue, Grammar parent)
	{

		this.parent = parent;

		enforce(jsonValue.type == JSONType.array, "input must comply to the tracery spec: symbol is not an array");
		foreach (value; jsonValue.arrayNoRef)
		{
			enforce(value.type == JSONType.string, "input must comply to the tracery spec: rule is not a string");
			dstring ruleString = dtext(value.str);
			dchar[] currentToken;

			Token[] tokens;

			bool hashOpen = false;

			foreach (c; ruleString)
			{
				if (c == '#')
				{
					hashOpen = !hashOpen;
					if (currentToken.length > 0)
					{
						if (hashOpen == false)
						{
							tokens ~= Token(text(currentToken), false);
							currentToken.length = 0;
						} else {
							tokens ~= Token(text(currentToken), true);
							currentToken.length = 0;
						}
					}
					continue;
				}
				currentToken ~= c;
			}

			if (currentToken.length > 0)
			{
				tokens ~= Token(text(currentToken), true);
			}

			rules ~= new Rule(tokens, this);
		}

	}
}

class Rule
{
	Token[] tokens;
	Symbol parent;

	this(Token[] tokens, Symbol parent)
	{
		this.tokens = tokens;
		this.parent = parent;
	}
}

struct Token
{
	string data;
	bool isLiteral;
}

class Trace
{
	void expand()
	{

	}

	string flatten()
	{
		return "";
	}
}

private string getFileString(string filename) @trusted
{
	char[] result;

	auto file = File(filename, "r");
	while (!file.eof())
	{
		result ~=  file.readln();
	}

	return result.idup;
}

@safe unittest
{
	auto fileString = getFileString("baba.json");

	auto jsonTree = parseJSON(fileString);
	//writeln(jsonTree.type);
	auto grammar = new Grammar(jsonTree);

	/*foreach(symbol; grammar.symbols)
	{
		foreach(rule; symbol.rules)
		{
			foreach(token; rule.tokens)
			{
				writeln(token.data);
			}
		}
	}*/

	//writeln(grammar.symbols["noun"].rules[0].tokens);

	writeln(grammar.createFlattened());
}
