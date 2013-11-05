/**
 * Copyright: Copyright (c) 2013 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Nov 5, 2013
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module dspec.config.Configuration;

import DStack = dstack.application.Configuration;

class Configuration : DStack.Configuration
{
	auto appName = "DSpec";
	auto appVersion = "0.0.1";

	this ()
	{
		super(this);
	}
}