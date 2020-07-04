#! /usr/bin/env raku

use v6.d;
use Test;

plan 4;

use Config;
use Config::Parser::NULL;

my Config $config = Config.new;
my Config::Parser $null-parser = Config::Parser::NULL;

throws-like { $config.read('t/files/none'.IO) }, X::Config::FileNotFound, 'Reading nonexisting file';

my %hash = %(
    "a" => "a",
    "b" => %(
        "c" => "test",
    ),
);

$config.read: %hash;

is-deeply $config.get, %hash, 'Correctly sets hash';

$config.=read: %(
    "b" => %(
        "d" => "another",
    ),
);

is-deeply $config.get, %(
    "a" => "a",
    "b" => %(
        "c" => "test",
        "d" => "another",
    ),
), "Correctly merges new hash into existing config";

subtest {
    plan 3;

    ok $config.read(("t/files/config".IO, "t/files/config.yaml".IO), $null-parser, :skip-not-found), "All paths exist";
    ok $config.read(("t/files/config".IO, "t/files/none".IO, "t/files/config.yaml".IO), $null-parser, :skip-not-found), "At least one path exists";
    ok $config.read(("t/files/none".IO, "t/files/none.yaml".IO), $null-parser, :skip-not-found), "No paths exist";
}, "Read with a List of paths";
