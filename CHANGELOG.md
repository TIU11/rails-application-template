# Changelog

Some notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project somewhat adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Highlights

- Using rails 5.2 with:
    - Twitter Bootstrap 3.3
    - Font Awesome 5.0 __(pending)__
- Lots of fixes, tweaks and improvements
- Minimize configuration in `application.rb`. Takes less work to keep project configs after applying the template.
- Use `application.scss` setup for theming
- Add types (ActiveModel::Type and ActiveRecord::Type)
    - `:phone_number` - for normalizing phone numbers
    - `:localized_date` - for handling date inputs
    - `:role` - simplifies/enhances role implementation
    - `:string` - provides `strip`, `squish` on string inputs
    - `:token` - for human-entered identifiers, like coupon codes
- Include environment info in `<head>` and non-production-page-footer
- Add `rubocop` and addressed (most) violations

### Changed

- Replace Virtus.model with ActiveModel::Attributes. Remains in `Gemfile` since some projects still use Virtus for array attributes.
- Upgraded font-awesome-sass 4 to 5. To migrate projects from earlier versions, use [font-awesome-migrator](https://bitbucket.org/tiu/font-awesome-migrator).

### Removed

- Extracted `populate` gem
- Removed `sass-rails` dependency

## 3.3.0 - 2017-05-04

- Using rails 5.0

## 3.2.0 - 2016-09-14

- Using rails 4.2.7
