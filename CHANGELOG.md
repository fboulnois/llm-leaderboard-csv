# Changelog

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
