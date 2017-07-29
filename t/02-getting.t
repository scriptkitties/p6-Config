#! /usr/bin/env perl6

use v6.c;
use Test;
use lib "lib";

plan 13;

use Config;

my $config = Config.new();

$config.read({
    a => "a",
    b => {
        c => "c"
    }
});

ok $config.get("a") eq "a", "Get simple key";
ok $config.get("b.c") eq "c", "Get nested key";
ok $config.get("nonexistant") === Nil, "Get nonexistant key";
ok $config.get("nonexistant", "test") === "test", "Get nonexistant key with default";

ok $config.get(["a"]) eq "a", "Get simple key by array";
ok $config.get(["b", "c"]) eq "c", "Get nested key by array";
ok $config.get(["nonexistant"]) === Nil, "Get nonexistant key by array";
ok $config.get(["nonexistant"], "test") === "test", "Get nonexistant key by array with default";

ok $config.<a> eq "a", "Get simple key via associative index";
ok $config.<b.c> eq "c", "Get nested key via associative index";
ok $config.<nonexistant> === Nil, "Get nonexistant key via associative index";

is $config.get(Nil), Nil, "Attempt to .get with Nil key";
is $config.get(Nil, "test"), "test", "Attempt .get with Nil key with default";
