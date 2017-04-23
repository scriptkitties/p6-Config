#! /usr/bin/env perl6

use v6.c;
use Test;
use lib "lib";

plan 6;

use Config;

my $config = Config.new();

$config.read({
    a => "a",
    b => {
        c => "c"
    }
});

ok $config.get("a") eq "a";
ok $config.get("b.c") eq "c";
ok $config.get("nonexistant") === Nil;

ok $config.get(["a"]) eq "a";
ok $config.get(["b", "c"]) eq "c";
ok $config.get(["nonexistant"]) === Nil;
