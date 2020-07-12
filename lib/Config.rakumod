#! /usr/bin/env false

use v6.d;

use Hash::Merge;
use IO::Glob;
use IO::Path::XDG;
use Log;

use Config::Parser;
use X::Config::AbstractParser;
use X::Config::FileNoExtension;
use X::Config::FileNotFound;
use X::Config::MissingParser;
use X::Config::NotSupported;

#| A simple, flexible Config class.
unit class Config does Associative;

#| The template for the configuration data structure.
has %.template;

#| The actual values to represent the configuration items.
has %.data;

#| The name for this Config object. The name is used for autodiscovery of
#| configuration values from the shell environment and standard configuration
#| file locations.
has Str $.name;

#| Create a new Config object.
method new (
	#| The template for the Config object. In its simplest form, this is
	#| just a Hash with all keys you want, including default values.
	%template = {},

	#| The name of the name.
	Str :$name,

	#| Immediately set some Config values. This is rarely desired for most
	#| use-cases.
	:%data? is copy,

	#| Try to read configuration data from the shell's environment.
	Bool:D :$from-env = True,

	#| Try to read configuration files from XDG_CONFIG_HOME and
	#| XDG_CONFIG_DIRS.
	Bool:D :$from-xdg = True,

	--> Config:D
) {
	%data ||= %template;

	%data = merge-hash(%data, self!read-from-env(%template, :$name)) if $from-env && $name;
	%data = merge-hash(%data, self!read-from-xdg-files(:$name)) if $from-xdg && $name;

	self.bless(
		:%template,
		:%data,
	)
}

#| Retrieve the entire Config object as a Hash.
multi method get (
	--> Hash:D
) {
	%!data
}

#| Retrieve a specific Config item at $key.
multi method get (
	#| The key to check at.
	Str:D $key,

	#| A default value, in case the key does not exist.
	Any $default = Nil,

	--> Any
) {
	self.get($key.split('.'), $default)
}

#| Retrieve a specific Config item specified by a list of nested keys.
multi method get (
	#| The list of nested keys.
	@parts,

	#| A default value, in case the key does not exist.
	Any $default = Nil,

	--> Any
) {
	my $index = %!data;

	for @parts {
		return $default unless $index{$_}:exists;

		$index = $index{$_};
	}

	$index;
}

#| Check whether the Config object has a value at $key.
multi method has (
	#| The key to check the existence of.
	Str:D $key,

	--> Bool:D
) {
	self.has($key.split('.'));
}

#| Check whether the Config object has a value at the location specified in
#| @parts.
multi method has (
	#| A list of the parts of the key to check the existence of.
	@parts,

	--> Bool:D
) {
	my $index = %!data;

	for @parts {
		return False unless $index{$_}:exists;
		last if $index ~~ Scalar;

		$index = $index{$_};
	}

	True;
}

#| Get a flat list of all keys in the Config object.
method keys (
	--> Iterable:D
) {
	self!recurse-keys(%!data)
}

#| Create a new Config object with %data merged in.
multi method read (
	#| A Hash of configuration data to merge in.
	%data,

	--> Config:D
) {
	Config.new(
		%!template,
		:$!name,
		data => merge-hash(%!data, %data),
		:!read-from-env,
		:!read-from-xdg,
	)
}

#| Update the Config values from a given file.
multi method read (
	#| The path to the configuration file.
	IO() $path,

	#| An explicit Config::Parser class to use. If left empty, it will be
	#| guessed based on the file's extension.
	Config::Parser:U $parser? is copy,

	--> Config:D
) {
	X::Config::FileNotFound.new(:$path).throw if !$path.f;

	# We need an implementation of Config::Parser, not the base
	# Config::Parser role.
	if ($parser.^name eq 'Config::Parser') {
		$parser = self!parser-for-file($path);
	}

	self.read(self!read-from-file($path, $parser));
}

#| Update the Config values from a list of files.
multi method read (
	#| A list of paths to configuration files to load.
	@paths,

	#| An explicit Config::Parser class to use. If left empty, it will be
	#| guessed based on each file's extension.
	Config::Parser:U $parser? is copy,

	#| Silently skip over files which don't exist.
	Bool:D :$skip-not-found = False,

	--> Config:D
) {
	my %data = %!data;

	for @paths -> $path {
		next if !$path.f && $skip-not-found;
		X::Config::FileNotFound.new(:$path).throw if !$path.f;

		# We need an implementation of Config::Parser, not the base
		# Config::Parser role.
		if ($parser.^name eq 'Config::Parser') {
			$parser = self!parser-for-file($path);
		}

		%data = merge-hash(%data, self!read-from-file($path, $parser));
	}

	self.read(%data);
}

#| Set a $key to $value.
multi method set (
	#| The key to change the value of.
	Str:D $key,

	#| The new value of the key.
	$value,

	--> Config:D
) {
	self.set($key.split('.'), $value);
}

#| Set a specific Config item specified by a list of nested keys to $value.
multi method set (
	#| A list of parts of the key to change the value of.
	@parts,

	#| THe new value of the key.
	$value,

	--> Config:D
) {
	my %data = %!data;
	my $index := %data;

	for @parts {
		$index := $index{$_};
	}

	$index = $value;

	Config.new(
		%!template,
		:$!name,
		:%data,
		:!read-from-env,
		:!read-from-xdg,
	)
}

#| Remove a key from the Config object.
multi method unset (
	#| The key to remove.
	Str:D $key,

	--> Config:D
) {
	self.unset($key.split('.'));
}

#| Remove a key from the Config object.
multi method unset (
	#| A list of parts of the key to remove.
	@parts,

	--> Config:D
) {
	my %data = %!data;
	my $index := %data;

	for 0..(@parts.elems - 2) {
		$index := $index{@parts[$_]};
	}

	$index{@parts[*-1]}:delete;

	Config.new(
		%!template,
		:$!name,
		:%data,
		:!read-from-env,
		:!read-from-xdg,
	)
}

#| Write the Config object to a file.
method write (
	#| The path to write the configuration values to.
	IO::Path:D $path,

	#| The Config::Parser object to use.
	Config::Parser:U $parser,

	--> Bool:D
) {
	if ($parser.^name eq 'Config::Parser') {
		X::Config::AbstractParser.new.throw;
	}

	$parser.write($path, %!data);
}

#| Return the default Config::Parser implementation for the given file. This is
#| based solely on the file's extension.
method !parser-for-file (
	#| The path to the file.
	IO::Path:D $path,

	--> Config::Parser:U
) {
	my $extension = $path.extension;

	X::Config::FileNoExtension.new(:$path).throw unless $extension;

	my $parser = "Config::Parser::$extension";

	.info("Loading $parser") with $Log::instance;

	try require ::($parser);

	return ::($parser) unless ::($parser) ~~ Failure;

	if (::($parser) ~~ Failure) {
		given (::($parser).exception) {
			when X::NoSuchSymbol {
				X::Config::MissingParser.new(:$parser).throw;
			}
			default {
				.alert("Failed to load $parser!") with $Log::instance;
			}
		}
	}

	Config::Parser
}

#| Read configuration data from environment variables.
method !read-from-env (
	#| The template in use by the Config object. This is needed to generate
	#| a list of the keys to check for.
	%template,

	#| The name of the application. This will be used to prefix the
	#| environment variables used.
	Str:D :$name is copy,

	--> Hash:D
) {
	my %data;

	$name ~= '.';

	self!recurse-keys(%template)
		.sort
		.map(sub ($key) {
			# Convert $key to something more reminiscient of
			# Shell-style variable names.
			my $var = "$name$key"
				.subst('.', '_', :g)
				.uc
				;

			# Check if the env var exists.
			.debug("Checking \$$var") with $Log::instance;

			return unless %*ENV{$var}:exists;

			# Insert the value from the env var into the data
			# structure.
			.info("Using \$$var for $key") with $Log::instance;

			my @key-parts = $key.split('.');
			my $index := %data;
			my $cast := %template;

			for @key-parts {
				last if $index ~~ Scalar;

				$index := $index{$_};
				$cast := $cast{$_};
			}

			# Cast the value appropriately
			given ($cast.WHAT) {
				when Numeric { $index = +%*ENV{$var} }
				when Str     { $index = ~%*ENV{$var} }
				when Bool    { $index = ?%*ENV{$var} }
				default      { $index =  %*ENV{$var} }
			}
		})
		;

	%data;
}

#| Read configuration data from a file.
method !read-from-file (
	#| The path to the file to read.
	IO::Path $file,

	#| An explicit Config::Parser to parse the file with. If left empty,
	#| the Config::Parser implementation to use will be deduced from the
	#| file's extension.
	Config::Parser:U $parser,

	--> Hash:D
) {
	if ($parser.^name eq 'Config::Parser') {
		X::Config::AbstractParser.new.throw;
	}

	# Use the Parser to read the file contents.
	$parser.read($file.absolute)
}

#| Check the XDG_CONFIG_DIRS and XDG_CONFIG_HOME locations for configuration
#| files, and load any that are found.
method !read-from-xdg-files (
	#| The name of the application. This will be used for the filename to
	#| look for.
	Str:D :$name,

	--> Hash:D
) {
	my %data;

	# Generate a list of all potential config file locations, based on the
	# XDG base directory spec.
	my @files = xdg-config-dirs()
		.reverse
		.map(sub ($dir) {
			(
				glob("$dir/$name.*").dir('/').map(*.IO).Slip,
				glob("$dir/$name/config.*").dir('/').map(*.IO).Slip;
			).Slip
		})
		;

	# Check each file.
	for @files -> $file {
		.debug("Checking $file") with $Log::instance;

		# Nothing to do if the file doesn't exist.
		next unless $file.f;

		.info("Reading config from $file") with $Log::instance;

		# Delegate to the file reader method.
		%data = merge-hash(%data, self!read-from-file($file, self!parser-for-file($file)));
	}

	%data;
}

#| Get a flat list of all available keys.
method !recurse-keys (
	#| The internal data Hash to generate a list of keys from.
	%data,

	#| The prefix to use. Only relevant for the recursive nature of this
	#| method.
	$prefix = '',

	--> Iterable:D
) {
	my @keys;

	for %data.keys -> $key {
		if (%data{$key} ~~ Hash) {
			@keys.append(self!recurse-keys(%data{$key}, "$key."));
			next;
		}

		@keys.append("$prefix$key")
	}

	@keys;
}

#| Implementation for Associative role. This is set here for the friendly error
#| message that can be generated with it.
method ASSIGN-KEY (::?CLASS:D: $key, $new)
{
	X::Config::NotSupported(
		call => 'ASSIGN-KEY',
		help => 'To set a key, use Config.set($key, $value)',
	).new.throw
}

#| Implementation for Associative role. This allows the user to retrieve a
#| Configuration key in the same way they'd retrieve an element from a Hash.
method AT-KEY (::?CLASS:D: $key)
{
	self.get($key)
}

#| Implementation for Associative role. This is set here for the friendly error
#| message that can be generated with it.
method DELETE-KEY (::?CLASS:D: $key)
{
	X::Config::NotSupported(
		call => 'DELETE-KEY',
		help => 'To remove a key, use Config.unset($key)',
	).new.throw
}

#| Implementation for Associative role. This allows the user to check for the
#| existence of a Configuration key in the same way they'd check existence of a
#| Hash key.
method EXISTS-KEY (::?CLASS:D: $key)
{
	self.has($key)
}

=begin pod

=NAME    Config
=VERSION 3.0.0
=AUTHOR  Patrick Spek <p.spek@tyil.work>

=begin LICENSE
Copyright © 2020

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License as published by the Free
Software Foundation, version 3.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
details.

You should have received a copy of the GNU Lesser General Public License along
with this program.  If not, see http://www.gnu.org/licenses/.
=end LICENSE

=end pod

# vim: ft=raku sw=8 ts=8 noet
