#! /usr/bin/env false

use v6.c;

use Hash::Merge;

use Config::Exception::MissingParserException;
use Config::Exception::UnknownTypeException;
use Config::Exception::FileNotFoundException;
use Config::Type;
use Config::Parser;

class Config is export
{
    has Hash $!content = {};
    has Str $!path;
    has Str $!parser;

    #| Clear the config.
    method clear()
    {
        $!content = {};
        $!path = "";
        $!parser = "";
    }

    #| Get a value from the config object. To get a nested
    #| key, use a . to descent a level.
    multi method get(Str $key, Any $default = Nil)
    {
        self.get($key.split("."), $default);
    }

    #| Get a value from the config object using an array
    #| to indicate the nested key to get.
    multi method get(Array $keyparts, Any $default = Nil)
    {
        my $index = $!content;

        for $keyparts -> $part {
            return $default unless defined($index{$part});

            $index = $index{$part};
        }

        $index;
    }

    #| Get the name of the parser module to use for the
    #| given path.
    method get-parser(Str $path, Str $parser = "")
    {
        if ($parser ne "") {
            return $parser;
        }

        my $type = self.get-parser-type($path);

        Config::Exception::UnknownTypeException.new(
            type => $type
        ).throw() if $type eq Config::Type::unknown;

        "Config::Parser::" ~ $type;
    }

    #| Get the type of parser required for the given path.
    method get-parser-type(Str $path)
    {
        given ($path) {
            when .ends-with(".yml") { return Config::Type::yaml; };
        }

        my $file = $path;

        if (defined($path.index("/"))) {
            $file = $path.split("/")[*-1];
        }

        if (defined($file.index("."))) {
            return $file.split(".")[*-1];
        }

        return Config::Type::unknown;
    }

    #| Check wether a given key exists.
    multi method has(Str $key) {
        self.has($key.split("."));
    }

    #| Check wether a given key exists using an array to supply
    #| the nested key to check.
    multi method has(Array $keyparts)
    {
        my $index = $!content;

        for $keyparts -> $part {
            return False unless defined($index{$part});

            $index = $index{$part};
        }
    }

    #| Reload the configuration. Requires the configuration to
    #| have been loaded from a file.
    multi method read()
    {
        if ($!path eq "") {
            return False;
        }

        return self.load($!path);
    }

    #| Load a configuration file from the given path. Optionally
    #| set a parser module name to use. If not set, Config will
    #| attempt to deduce the parser to use.
    multi method read(Str $path, Str $parser = "")
    {
        Config::Exception::FileNotFoundException.new(
            path => $path
        ).throw() unless $path.IO.f;

        $!parser = self.get-parser($path, $parser);

        try {
            CATCH {
                when X::CompUnit::UnsatisfiedDependency {
                    Config::Exception::MissingParserException.new(
                        parser => $parser
                    ).throw();
                }
            }

            require ::($!parser);

            self.read(::($!parser).read($path));
        }

        return True;
    }

    #| Read an array of paths. Will fail on the first file that
    #| fails to load for whatever reason.
    multi method read(Array $paths, Str $parser = "")
    {
        for $paths -> $path {
            self.read($path, $parser);
        }

        return True;
    }

    #| Read a plain Hash into the configuration.
    multi method read(Hash $hash)
    {
        $!content.merge($hash);

        return True;
    }

    #| Set a single key to a given value;
    method set(Str $key, Any $value)
    {
        my $index := $!content;

        for $key.split(".") -> $part {
            $index{$part} = {} unless defined($index{$part});

            $index := $index{$part};
        }

        $index = $value;

        self;
    }

    #| Write the current configuration to the given path. If
    #| no parser is given, it tries to use the parser that
    #| was used when loading the configuration.
    method write(Str $path, Str $parser = "")
    {
        $parser = self.get-parser($path, $parser);

        require ::($parser);
        return ::($parser).write($path, $!content);
    }
}
