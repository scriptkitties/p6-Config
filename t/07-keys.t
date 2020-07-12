#! /usr/bin/env raku

use v6;

use Config::Parser::NULL;
use Config;
use Test;

plan 1;

my Config $c .= new.read: %(
	"a" => False,
	"b" => False,
	"c" => %(
		"a" => False,
		"b" => False,
	),
);

my @keys = < a b c.a c.b >;

is $c.keys.sort, @keys, ".keys returns a list of all keys";

# vim: ft=raku noet
