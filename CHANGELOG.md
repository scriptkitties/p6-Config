# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic
Versioning](http://semver.org/spec/v2.0.0.html).

## [3.0.3] - 2020-11-16

Due to a user error, version 3.0.2 has been skipped.

### Changed

- Updated tests supplied with Config.

## [3.0.1] - 2020-11-12

### Changed

- `.read` now uses `%!data.clone`, instead of `%!data`. This should fix an
  issue where the `Hash` used is shared between the objects, resulting in
  hard-to-debug errors.

## [3.0.0] - 2020-07-12

`Config` has been rebuilt from the ground up. This is a relatively old
project of mine, which I used to get into Raku. I've learned many new things
in the past couple years, many things of which have been applied to this
project.

Much of the user-facing interface is the same, however, breaking some backwards
compatibility was inevitable with some of the new ways I wanted `Config` to
function. Please read through this CHANGELOG carefully, and consider reading
the documentation if you encounter issues. If you have any questions or
remarks, you can also send an email to `~tyil/raku-devel@lists.sr.ht`.

### Added

- `.new` now (optionally) accepts a `Hash` which will be used as a template.
  From this template, environment variables will be checked for existence, and
  used if they exist. You must also set a `:name` attribute, which will be used
  as a prefix for all the variables. This should make it easier to include
  environment variable based configuration in applications.

  Additionally, if the `:name` attribute is set, a number of standard
  directories will be probed to see if there's a usable configuration file to
  read. Which directories to probe is based on the [XDG Base Directory
  Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html).

  Both environment and XDG-path based auto-loading of configuration can be
  turned off with `:!from-env` and `:!from-xdg` respectively.

- [`Log`](https://modules.raku.org/dist/Log:cpan:TYIL) is now included to
  provide some debug logging. Any application using this will get logging in
  their preferred format through this.

### Changed

- The `Config` object is now immutable. Calling methods that alter the
  configuration values (such as `.read`, `.set`, `.unset`) will now return a
  new `Config` object. Raku has a very pretty [`.=`
  operator](https://docs.raku.org/language/operators#infix_.=) that may come in
  handy!

- The `Exception` classes are now in `X::Config`, and the redundant `Exception`
  suffix has been removed.

- When setting an explicit parser, the parser must be given as a type object,
  instead of a `Str`. This will lead to potential issues being known at
  compile-time, rather than runtime.

- `Config`'s license has changed from `AGPL-3.0` to `LGPL-3.0-only`. The Lesser
  General Public License allows use of `Config`, even in closed code bases.
  This should make the module more usable for all sorts of people, while still
  maintaining a strong focus on keeping it Free Software.

## [2.1.0] - 2018-08-26

### Added

- `.clone` method now exists to create a clone of the Config object.

## [2.0.0] - 2018-08-26

### Changed

- `.read` will now return the `Config` object, instead of a `Bool`.

## [1.3.5] - 2018-03-28

### Added

- `api` key to META6.json

### Changed

- Update dependency to `Hash::Merge` to use `api` and `version` adverbs

### Removed

- Lingering say statement in get-parser, breaking tests for Rakudo Star users
  ([GitHub#4](https://github.com/scriptkitties/p6-Config/issues/4))

- Useless `use lib "lib"` statements from tests

- Useless dd statement from tests

## [1.3.3] - 2018-03-20

### Added

- A CHANGELOG is now present to keep track of changes between versions

### Changed

- Fix `:delete` adverb
