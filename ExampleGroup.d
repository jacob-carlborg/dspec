/**
 * Copyright: Copyright (c) 2010-2012 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Oct 17, 2010
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 * 
 */
module dspec.ExampleGroup;

import mambo.core._;
import mambo.util._;

package final class ExampleGroup
{
	alias .Block!(void delegate (), string) Block;
	alias void delegate () Callback;

	struct ExampleGroupManager
	{
		ExampleGroupContext[] exampleGroups;
		size_t lastIndex = size_t.max;
		
		void opCatAssign (ExampleGroupContext exampleGroup)
		{
			exampleGroup ~= exampleGroup;
			lastIndex++;
		}
		
		void opCatAssign (Example example)
		{
			last.tests ~= example;
		}
		
		ExampleGroupContext opIndex (size_t i)
		{
			return exampleGroups[i];
		}
		
		ExampleGroupContext last ()
		{
			return exampleGroups[$ - 1];
		}
		
		ExampleGroupContext first ()
		{
			return exampleGroups[0];
		}
		
		int opApply (int delegate(ref ExampleGroupContext) dg)
		{
			int result = 0;
			
			foreach (ex ; exampleGroups)
			{
				result = dg(ex);
				
				if (result)
					return result;
			}
			
			return result;
		}
		
		size_t length ()
		{
			return exampleGroups.length;
		}
	}

	class ExampleGroupContext
	{
		private
		{
			ExampleGroupManager exampleGroups;
			Example[] tests;
			Example[] failures;
			Example[] pending;
			size_t lastIndex = size_t.max;
			string description;
			void delegate () block;
		}
		
		this (string description)
		{
			this.description = description;
		}
		
		void run ()
		{
			if (shouldRun)
				block();
		}
		
		bool shouldRun ()
		{
			return block !is null;
		}
	}

	struct Example
	{
		void delegate () block;
		string description;
		AssertException exception;
		
		bool failed ()
		{
			return !succeeded;
		}
		
		bool succeeded ()
		{
			if (exception is null)
				return true;
			
			return false;
		}
		
		void run ()
		{
			if (!isPending)
				block();
		}
		
		bool isPending ()
		{
			return block is null;
		}
	}

	private static ExampleGroup instance_;

	ExampleGroupManager exampleGroups;
	ExampleGroupContext currentExampleGroup;
	
 	Callback before_;
	Callback after_;
	
	size_t numberOfFailures;
	size_t numberOfPending;
	size_t numberOfExamples;
	size_t failureId;
	
	string defaultIndentation = "    ";
	string indentation;

	static ExampleGroup instance ()
	{
		return instance_ = instance_ ? instance_ : new ExampleGroup;
	}

	/// A callback that will be called after each example.
	@property Callback after ()
	{
		return after_;
	}

	/// Ditto
	@property Callback after (Callback callback)
	{
		return after_ = callback;
	}

	/// A callback that will be called before each example.
	@property Callback before ()
	{
		return before_;
	}

	/// Ditto
	@property Callback before (Callback callback)
	{
		return before_ = callback;
	}

	Block describe (string description) ()
	{
		addExampleGroup(description);

		Block block;
		block.args[0] = &internalDescribe;
		block.args[1] = description;

		return block;
	}

	Block it (string description) ()
	{
		addExample(description);

		Block block;
		block.args[0] = &internalExample;
		block.args[1] = description;

		return block;
	}

	void run ()
	{
		foreach (exampleGroup ; exampleGroups)
			runExampleGroup(exampleGroup);

		printResult();
	}

private:

	void runExampleGroup (ExampleGroupContext context)
	{
		restore(currentExampleGroup) in {
			currentExampleGroup = context;
			currentExampleGroup.run();

			foreach (c ; context.exampleGroups)
				runExampleGroup(c);

			foreach (example ; context.examples)
			{
				if (example.isPending)
					addPendingExample(context, example);

				try
				{
					execute in {
						execute.run();
					};
				}

				catch (AssertException e)
					handleFaliure(context, example, e);
			}
		};
	}

	void addExampleGroup (string description)
	{
		auto exampleGroups = currentExampleGroup ? currentExampleGroup.exampleGroups : this.exampleGroups;
		exampleGroups ~= new ExampleGroupContext(description);
	}

	void addExample (string description)
	{
		numberOfExamples++;
		currentExampleGroup.example ~= Example(null, description);
	}

	void addPendingExample (ExampleGroupContext context, ref Example example)
	{
		numberOfPending++;
		context.pending ~= example;
	}

	void handleFaliure (ExampleGroupContext context, ref Example example, AssertException exception)
	{
		numberOfFaliures++;
		example.exception = exception;
		context.faliures ~= example;
	}

	void internalDescribe (void delegate () block, string description)
	{
		if (currentExampleGroup)
			currentExampleGroup.exampleGroups.last.exampleGroup = block;

		else
			exampleGroups.last.exampleGroup = block;
	}

	void internalExample (void delegate () block, string description)
	{
		currentExampleGroup.examples[$ - 1] = Example(block, description);
	}

	void printResult ()
	{
		if (isAllExamplesSuccessful)
			return printSuccess();

		foreach (exampleGroup ; exampleGroups)
		{
			printExampleGroup(exampleGroup);
			printResultImpl(exampleGroup.exampleGroups);
		}

		failureId = 0;
		printPending();
		printFaliures();

		print("\n", numberOfExamples, " ", pluralize("test", numberOfExamples),", ", numberOfFailures, " ", pluralize("failure", numberOfFailures));
		printNumberOfPending();
		println();
	}

	void printResultImpl (ExampleGroupManager exampleGroups)
	{
		restore(indentation) in {
			indentation ~= defaultIndentation;

			foreach (exampleGroup ; exampleGroups)
			{
				printExampleGroup(exampleGroup);
				printResultImpl(exampleGroup.exampleGroups);
			}
		};
	}

	void printExampleGroup (ExampleGroupContext exampleGroup)
	{
		println(indentation, exampleGroup.description);

		restore(indentation) in {
			indentation ~= defaultIndentation;

			foreach (i, ref example ; exampleGroup.example)
			{
				print(indentation, "- ", example.description);

				if (example.isPending)
					print(" (PENDING: Not Yet Implemented)");

				if (example.failed)
					print(" (FAILED - ", ++failureId, ')');

				println();
			}
		};
	}

	void printPending ()
	{
		if (!hasPending)
			return;

		println("\nPending:");

		restore(indentation) in {
			indentation ~= defaultIndentation;

			foreach (exampleGroup ; exampleGroups)
			{
				printPendingExampleGroup(exampleGroup);
				printPendingImpl(exampleGroup.exampleGroups);
			}
		};
	}

	void printPendingImpl (ExampleGroupManager exampleGroups)
	{
		foreach (exampleGroup ; exampleGroups)
		{
			printPendingExampleGroup(exampleGroup);
			printPendingImpl(exampleGroup.exampleGroups);
		}
	}

	void printPendingExampleGroup (ExampleGroupContext exampleGroup)
	{
		foreach (example ; exampleGroup.pending)
			println(indentation, exampleGroup.description, " ", example.message, "\n", indentation, indentation, "# Not Yet Implemented");
	}

	void printFailures ()
	{
		if (!hasFailures)
			return;

		println("\nFailures:");

		restore(indentation) in {
			indentation ~= defaultIndentation;

			foreach (exampleGroup ; exampleGroups)
			{
				printFailuresExampleGroup(exampleGroup);
				printFailuresImpl(exampleGroup.exampleGroups);
			}
		};
	}

	void printFailuresImpl (ExampleGroupManager exampleGroups)
	{
		foreach (exampleGroup ; exampleGroups)
		{
			printFailuresDescription(exampleGroup);
			printFailuresImpl(exampleGroup.exampleGroups);
		}
	}

	void printFailuresDescription (ExampleGroupContext exampleGroup)
	{
		foreach (example ; exampleGroup.failures)
		{
			auto str = indentation ~ to!(string)(++failureId) ~ ") ";
			auto whitespace = toWhitespace(str.length);

			println(str, exampleGroup.description, " ", example.description);			
			println(whitespace, "# ", example.exception.file, ".d:", example.exception.line);
			println(whitespace, "Stack trace:");
			print(whitespace);

			version (Tango)
			{
				test.exception.writeOut(&printStackTrace);
				println();
				println(readFailedTest(test));
			}				
		}
	}

	void printNumberOfPending ()
	{
		if (hasPending)
			print(", ", numberOfPending, " pending");
	}
	
	void printSuccess ()
	{
		println("All ", numberOfExamples, pluralize(" test", numberOfExamples), " passed successfully.");
	}
	
	bool isAllTestsSuccessful ()
	{
		return !hasPending && !hasFailures;
	}
	
	bool hasPending ()
	{
		return numberOfPending > 0;
	}
	
	bool hasFailures ()
	{
		return numberOfFailures > 0;
	}
	
	Use!(void delegate ()) execute ()
	{
		Use!(void delegate ()) use;
		
		use.args[0] = &executeImpl;
		
		return use;
	}
	
	void executeImpl (void delegate () dg)
	{
		auto before = this.before;
		auto after = this.after;
		
		if (before) before();
		if (dg) dg();
		if (after) after();
	}
	
	string toWhitespace (size_t value)
	{
		string str;
		
		for (size_t i = 0; i < value; i++)
			str ~= ' ';
		
		return str;
	}
}