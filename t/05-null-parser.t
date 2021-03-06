#! /usr/bin/env raku

use v6.c;
use Test;

use Config;
use Config::Parser::NULL;

plan 3;

Config::Parser::NULL.set-config({
    "a" => "a",
    "b" => {
        "c" => "c"
    }
});

my Config $config = Config.new;

ok $config.=read('t/files/config'.IO, Config::Parser::NULL), "Attempt to read a file with Config::Parser::NULL";

is-deeply $config.get, {
    "a" => "a",
    "b" => {
        "c" => "c"
    }
}, "Check read config from Config::Parser::NULL";

ok $config.write('t/t/t'.IO, Config::Parser::NULL), "Attempt to write a file with Config::Parser::NULL";
