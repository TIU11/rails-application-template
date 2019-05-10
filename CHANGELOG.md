# Changelog

Some notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project somewhat adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Font Awesome 5.0 __(pending)__

### Removed

- Remove generator_helper, which is now in the tiu-generators gem, https://bitbucket.org/tiu/tiu-generators.
  Clean it out of your app with: `rm ./lib/helpers/generator_helper.rb`

## 4.0 - 2019-05-03

### Highlights

- Using rails 5.2 with:
    - Twitter Bootstrap 3.3
- Lots of fixes, tweaks and improvements
- Minimize configuration in `application.rb`. Takes less work to keep project configs after applying the template.
- Use `application.scss` setup for theming
- Add types (ActiveModel::Type and ActiveRecord::Type)
    - `:editor_text` - strips out empty spaces that are default on Ckeditor 5
    - `:phone_number` - for normalizing phone numbers
    - `:localized_date` - for handling date inputs
    - `:role` - simplifies/enhances role implementation
    - `:string` - provides `strip`, `squish` on string inputs
    - `:token` - for human-entered identifiers, like coupon codes
    - `:zip` - for USPS ZIP code
- Include environment info in `<head>` and non-production-page-footer
- Add `rubocop` and addressed (most) violations

### Changed

- Replace Virtus.model with ActiveModel::Attributes. Remains in `Gemfile` since some projects still use Virtus for array attributes.
- Upgraded font-awesome-sass 4 to 5. To migrate projects from earlier versions, use [font-awesome-migrator](https://bitbucket.org/tiu/font-awesome-migrator).
- Improve browser detection for unsupported browser message using `browser` gem.
- Assume yarn + webpacker, so include in generator examples, Capistrano :linked_dirs config.

### Removed

- Extracted `populate` gem
- Removed `sass-rails` dependency
- Removed generators and templates. They're now in the tiu-generators gem, https://bitbucket.org/tiu/tiu-generators.
  Clean them out from your app with:
  ```
  rm -rfv ./lib/generators/{all,angularjs,authlogic,tiu}
  rm -rfv ./lib/templates/{active_record,erb}
  ```

## 3.3.0 - 2017-05-04

- Using rails 5.0

## 3.2.0 - 2016-09-14

- Using rails 4.2.7
