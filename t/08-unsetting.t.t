#! /usr/bin/env raku

use v6.c;
use Test;

plan 4;

use Config;

my $config = Config.new;

$config.=read: %(
	a => "b",
	c => %(
		d => "e",
	),
);

ok $config.has("c.d"), "'c.d' exists";
ok $config.unset("c.d"), "'c.d' gets deleted";
nok $config.has("c.d"), "'c.d' no longer exists";
ok $config.has("c"), "'c' still exists";
