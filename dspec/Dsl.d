/**
 * Copyright: Copyright (c) 2010-2012 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Oct 17, 2010
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 * 
 * This is a simple unit test framework inspired by rspec. This framework is used for
 * collecting unit test failures (assert exceptions) and presents them to the user in a
 * nice format.
 * 
 * The following are features of how a test report is printed:
 * 
 * $(UL
 * 	$(LI print the filename and line number of the failing test)
 * 	$(LI print the description of a failing or pending test)
 * 	$(LI print a snippet of the file around a failing test)
 * 	$(LI print the stack trace of a failing test)
 * 	$(LI print the number of failing, pending and passed test.
 * 		As well as the total number of tests)
 * 	$(LI minimal output then all tests pass)
 * )
 * 
 * If an assertion fails in a "it" block, that block will end. No other block is affected
 * by the failed assertion. 
 * 
 * Examples:
 * ---
 * import orange.test.UnitTester;
 * 
 * int sum (int x, int y)
 * {
 * 	return x * y;
 * }
 * 
 * unittest ()
 * {
 * 	describe("sum") in {
 * 		it("should return the sum of the two given arguments") in {
 * 			assert(sum(1, 2) == 3);
 * 		}
 * 	}
 * }
 * 
 * void main ()
 * {
 * 	run;
 * }
 * ---
 * When the code above is run, it would print, since the test is failing, something similar:
 * ---
 * sum
 *   - should return the sum of the given arguments
 *
 * Failures:
 *     1) sum should return the sum of the given arguments
 *        # main.d:44
 *        Stack trace:
 *        tango.core.Exception.AssertException@main(44): Assertion failure
 * 
 * 	
 * describe("sum") in {
 * 	it("should return the sum of the given arguments") in {
 * 		assert(sum(1, 2) == 3);
 * 	};
 * };
 * 	
 * 1 test, 1 failure
 * ---
 */
module dspec.Dsl;

import mambo.core._;
import mambo.util._;

import dspec.ExampleGroup;

/**
 * Describes a test or a set of tests.
 * 
 * Examples:
 * ---
 * unittest ()
 * {
 * 	describe("the description of the tests") in {
 * 
 * 	};
 * }
 * ---
 * 
 * Params:
 *     message = the message to describe the test
 *     
 * Returns: a context in which the tests will be run
 */
Block describe (string description) ()
{
	return ExampleGroup.instance.describe(description);
}

/**
 * Describes what a test should do.
 * 
 * Examples:
 * ---
 * unittest ()
 * {
 * 	describe("the description of the tests") in {
 * 		it("should do something") in {
 * 			// put your assert here
 * 		};
 * 
 * 		it("should do something else") in {
 * 			// put another assert here
 * 		}
 * 	};
 * }
 * ---
 * 
 * Params:
 *     message = what the test should do
 *     
 * Returns: a context in which the test will be run 
 */
Block it (string description) ()
{
	return ExampleGroup.instance.it(description);
}

/// A callback that will be called after each example.
@property Callback after ()
{
	return ExampleGroup.instance.after;
}

/// Ditto
@property Callback after (Callback callback)
{
	return ExampleGroup.instance.after = callback;
}

/// A callback that will be called before each example.
@property Callback before ()
{
	return ExampleGroup.instance.before;
}

/// Ditto
@property Callback before (Callback callback)
{
	return ExampleGroup.instance.before = callback;
}