/**
 * Copyright: Copyright (c) 2013 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Nov 5, 2013
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module dspec.app.DStep;

import dspec.app.Application;
import dspec.config.Configuration;

int main (string[] args)
{
	Application.instance.config = new Configuration;
	return Application.start!Application(args);
}
