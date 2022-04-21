# Readymade 0.2.1

This gems contains basic components to follow [ABDI architecture](https://github.com/OrestF/OrestF/blob/master/abdi/ABDI_architecture.md)

### Tested with ruby:

- 3.1
- 3.0
- 2.7

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'readymade'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install readymade

## Usage

Inherit your components from:
* `Readymade::Response`
* `Readymade::Form`
* `Readymade::InstantForm`
* `Readymade::Action`
* `Readymade::Operation`

### Readymade::Response

```ruby
response = Readymade::Response.new(:success, my_data: data)
response.success? # true
response = Readymade::Response.new(:fail, errors: errors)
response.success? # false
response.fail? # true
response.status # 'fail'
response.data # { errors: { some: 'errors' } }
```

### Readymade::Form

Check more form features examples in `lib/readymade/form.rb`
```ruby
class Orders::Forms::Create < Readymade::Form
  PERMITTED_ATTRIBUTES = %i[email name category country customer]
  REQUIRED_ATTRIBUTES = %i[email]

  validates :customer, presence: true, if: args[:validate_customer]
end

order_form = Orders::Forms::Create.new(params, order: order, validate_customer: false)

order_form.valid? # true


```

#### form_options

```ruby
# app/forms/my_form.rb

class MyForm < Readymade::Form
  PERMITTED_ATTRIBUTES = %i[email name category country]
  REQUIRED_ATTRIBUTES = %i[email]
  
  def form_options
    {
      categories: args[:company].categories,
      countries: Country.all
    }
  end
end
```

```ruby
# app/controllers/items_controller.rb

def new
  @form = MyForm.form_options(company: current_company)
end
```

```slim
/ app/views/items/new.html.slim

= f.select :category, collection: @form[:categories]
= f.select :country, collection: @form[:countries]
= f.text_field :email, required: @form.required?(:email) # true
= f.text_field :name, required: @form.required?(:name) # false
```

### Readymade::InstantForm

Permit params and validates presence inline

```ruby
Readymade::InstantForm.new(my_params, permitted: %i[name phone], required: %i[email]) # permits: name, phone, email; validates on presence: email
```

### Readymade::Action

```ruby
class Orders::Actions::SendNotifications < Readymade::Action
  def call
    send_email
    send_push
    send_slack

    response(:success, record: record, any_other_data: data)
  end
end
```

```ruby
response = Orders::Actions::SendNotifications.call(order: order)

response.fail? # false
response.success? # true
response.data[:record]
response.data[:any_other_data]
```

### Readymade::Operation

Provides set of help methods like: `build_form`, `form_valid?`, `validation_fail`, `save_record`, etc.
```ruby
class Orders::Operations::Create < Readymade::Operation
  def call
    build_record
    build_form
    return validation_fail unless form_valid?

    assign_attributes
    return validation_fail unless record_valid?

    save_record

    success(record: record)
  end
end
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/OrestF/readymade. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/readymade/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Lead project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/readymade/blob/master/CODE_OF_CONDUCT.md).
