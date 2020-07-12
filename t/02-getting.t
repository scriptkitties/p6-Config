#! /usr/bin/env raku

use v6.c;
use Test;

plan 13;

use Config;

my Config $config = Config.new();

$config.read({
    a => "a",
    b => {
        c => "c"
    }
});

is $config.get("a"), "a", "Get simple key";
is $config.get("b.c"), "c", "Get nested key";
is $config.get("nonexistent", "test"), "test", "Get nonexistent key with default";
ok $config.get("nonexistent") === Nil, "Get nonexistent key";

is $config.get(["a"]), "a", "Get simple key by array";
is $config.get(["b", "c"]), "c", "Get nested key by array";
is $config.get(["nonexistent"], "test"), "test", "Get nonexistent key by array with default";
ok $config.get(["nonexistent"]) === Nil, "Get nonexistent key by array";

is $config<a>, "a", "Get simple key via associative index";
is $config<b.c>, "c", "Get nested key via associative index";
is $config<nonexistent>, Nil, "Get nonexistent key via associative index";

is $config.get('nonexistent', "test"), "test", "Attempt .get with nonexistent key with default";
is $config.get('nonexistent'), Nil, "Attempt to .get with nonexistent key";
