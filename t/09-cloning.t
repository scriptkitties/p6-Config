#! /usr/bin/env raku

use v6.c;

use Test;

use Config;

plan 2;

my $a = Config.new.read: %(
	foo => "bar",
	baz => 42,
);

my Config $b = $a.clone;

is-deeply $a.get, $b.get, "B contains the same data as A";
isnt $a, $b, "A and B are not the same object";

# vim: ft=raku noet
