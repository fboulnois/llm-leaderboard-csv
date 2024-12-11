# Changelog

## [v1.2.3](https://github.com/fboulnois/llm-leaderboard-csv/compare/v1.2.2...v1.2.3) - 2024-12-11

### Fixed

* Use new llm leaderboard api

## [v1.2.2](https://github.com/fboulnois/llm-leaderboard-csv/compare/v1.2.1...v1.2.2) - 2024-10-14

### Fixed

* Update lmsys arena url to new location

## [v1.2.1](https://github.com/fboulnois/llm-leaderboard-csv/compare/v1.2.0...v1.2.1) - 2024-08-13

### Fixed

* Downgrade to 4.4.0 to avoid broken packages

## [v1.2.0](https://github.com/fboulnois/llm-leaderboard-csv/compare/v1.1.0...v1.2.0) - 2024-07-12

### Added

* Add the new huggingface leaderboard

### Changed

* Move header normalization functions

## [v1.1.0](https://github.com/fboulnois/llm-leaderboard-csv/compare/v1.0.0...v1.1.0) - 2024-07-06

### Added

* Run action every day at 11am
* Add pipeline to commit and upload csv outputs
* Add pipeline to create and copy csv outputs
* Add dummy action to checkout code

### Fixed

* Always create csv directory if missing
* Rename arena_elo to arena_score
* Only extract first index
* Temporarily use old leaderboard

## [v1.0.0](https://github.com/fboulnois/llm-leaderboard-csv/releases/tag/v1.0.0) - 2024-06-19

### Added

* Add huggingface and lmsys csv outputs
* Add Makefile to build and run Dockerfile
* Add build using Dockerfile
* Add script to get huggingface and lmsys csv
