# Changelog

## [0.2.0](https://github.com/CrowdHailer/eex_html/tree/0.2.0) - 2018-11-13

### Changed

- `EExHTML.Engine` returns content wrapped in a `EExHTML.Safe` struct,
  this removes the requirements for templates that produced a list of content to explicitly mark it safe.

## [0.1.1](https://github.com/CrowdHailer/eex_html/tree/0.1.1) - 2018-09-12

### Fixed

- `EExHTML.javascript_variables/1` was adding an extra unnecessary `"` to the page.

## [0.1.0](https://github.com/CrowdHailer/eex_html/tree/0.1.0) - 2018-09-11

Initial release
