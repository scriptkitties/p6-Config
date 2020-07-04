#! /usr/bin/env false

use v6.d;

use Config::Parser;

#| The Config::Parser::NULL is a parser to mock with for testing purposes.
#| It exposes an additional method, set-config, so you can set a config
#| Hash to return when calling `read`.
unit class Config::Parser::NULL is Config::Parser;

my %mock-config;

#| Return the mock config, skipping the file entirely.
multi method read(IO() $path --> Hash)
{
	%mock-config;
}

#| Set the mock config to return on read.
method set-config(Hash $config)
{
	%mock-config = $config;
}

#| Return True, as if writing succeeded.
multi method write(IO() $path, Hash $config --> Bool)
{
	True;
}
