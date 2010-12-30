# SimpleModel

## Installation


SimpleModel is available through [Rubygems](http://rubygems.org/gems/simple_model) and can be installed via:

    $ gem install simple_model

## Usage
### Basic
      require 'simple_model'

        class Item < SimpleModel::Base
          has_booleans :active
          has_currency :total_amount_due

          private
          def validate
            validates_presence_of :total_amount_due
          end
        end
        
        item = Item.new
        item.active = true
        item.total_amount_due = "$5.00" # time.total_amount_due => 5.0

### Validation and Errors only

     require 'simple_model'

        class Item
          include SimpleModel::Validation
          include SimpleModel::Errors

          attr_accessor :foo

          private
          def validate
            validates_presence_of :foo
          end
        end

        item = Item.new
        item.valid? # => false

### Validation Only - helpful if your class already has an errors object, but lacks built in validation

     require 'simple_model'

        class Item < SimpleRecord::Base
          include SimpleModel::Validation

          attr_accessor :foo

          private
          def validate
            validates_presence_of :foo
          end
        end

        item = Item.new
        item.valid? # => false

## Contributing to simple_model
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Thanks

Code based on Rails/ActiveRecord and [Appoxy/SimpleRecord](https://github.com/appoxy/simple_record)
