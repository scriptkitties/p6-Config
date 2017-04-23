#! /usr/bin/env perl6

use v6.c;
use Test;
use lib "lib";

plan 2;

use Config;

my $config = Config.new();

$config.read({
    a => "a",
    b => {
        c => "c"
    }
});

ok $config.has("a");
ok $config.has("b.c");
