# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic
Versioning](http://semver.org/spec/v2.0.0.html).

## [UNRELEASED]

### Changed

- The `.read` and `.write` methods of a `Config` object now support `IO::Path`
  as arguments for the `$path`, in addition to supporting the `Str` based
  `$path` argument. *I intend to deprecate the `Str` variant in the future*.

  Related links:

  - [`GitHub#5`](https://github.com/scriptkitties/p6-Config/issues/5)

  Special thanks to:

  - [taboege](https://github.com/taboege)

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
