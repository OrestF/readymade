Changelog
All notable changes to this project will be documented in this file.

## [0.4.0] - 2023-06-22

* Add `.call!` method to `Readymade::Action` to raise an error if not success
* Add `.call_async!` method to `Readymade::Action` to raise an error in background if not success

## [0.3.0] - 2023-03-14

* Add `.call_async` method to `Readymade::Action` to run service in background

## [0.2.8] - 2022-11-10

### Fixes

* Fix `Readymade::Controller::Serialization` collection_response method raised an error.

## [0.2.7] - 2022-06-03

### Improvement

* Update `Readymade::Model::ApiAttachable` to support browser native base64 encoding

## [0.2.6] - 2022-05-24

### Features

* Add `Readymade::Model::Filterable` - model concern for scopes filtering

## [0.2.5] - 2022-05-19

### Improvements

* Form#required_attributes returns `[]` if `params[:_destroy]` present

## [0.2.4] - 2022-05-12

### Fixes

* Fix ApiAttachable empty attachments for non hash assignement

## [0.2.3] - 2022-05-03

### Features

* Add `Readymade::Model::ApiAttachable` - add base64 format to your ActiveStorage

## [0.2.1] - 2022-04-21

### Improvements

* Update collection_response controller helper

## [0.2.0] - 2022-04-13

### Improvements

* Add support for ruby 3.0, 3.1

## [0.1.8] - 2022-03-30

### Improvements

* Improve README.md and form examples

## [0.1.6] - 2021-12-20

### Features

* Add Readymade::Controller::Serialization

## [0.1.5] - 2021-12-07

### Improvements

* Better errors with Rails 6.1.

## [0.1.4] - 2021-11-22

### Features

* Add `Readymade::InstantForm`

### Improvements

* Call `build_form` inside `form_valid?` if `@form` is not defined

## [0.1.3] - 2021-11-20

### Improvements

* Fix error when required param for instant form is not defined
