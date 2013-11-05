/**
 * Copyright: Copyright (c) 2013 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Nov 5, 2013
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module dspec.app.Application;

import mambo.core._;
import mambo.util.Singleton;

import DStack = dstack.application.Application;

class Application : DStack.Application
{
	mixin Singleton;

	enum Version = "0.0.1";

	protected override void run ()
	{
		println("asd");
	}

    protected override void setupArguments ()
	{

	}
}