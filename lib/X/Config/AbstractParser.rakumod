#! /usr/bin/env false

use v6.d;

unit class X::Config::AbstractParser is Exception;

method message
{
	'You must use an implementation class of Config::Parser, not the base role'
}

=begin pod

=NAME    X::Config::AbstractParser
=VERSION 3.0.3
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

# vim: ft=raku noet sw=8 ts=8
