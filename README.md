# SimpleModel
A collection of convenience methods for building table-less models. 
SimpleModel implements:

* ActiveModel::Validations
* ActiveModel::Conversion
* ActiveModel::Validations::Callbacks
* ActiveModel::Dirty
* ActiveModel::Naming
* ActiveModel::Callbacks
* ActiveSupport core extentions (see [SimpleModel::Base](https://github.com/JoshMcKin/simple_model/blob/master/lib/simple_model/base.rb))

Additionally SimpleModel implements basic model actions

## Installation


SimpleModel is available through [Rubygems](http://rubygems.org/gems/simple_model) and can be installed via:

    $ gem install simple_model

## Usage
### Basic
      require 'simple_model'

        class Item < SimpleModel::Base
          # Model Actions
          save :save_item, :rollback => :undo_save
          
          # Callbacks
          before_validation :add_to_array
          
          # Attributes
          has_booleans :active, :default => true
          has_booleans :paid
          has_currency :price, :default => 10.0.to_currency
          has_times :created_at, :default => :now
          has_attribute :my_array, :default => []
          
          # Validation
          validates_inclusion_of :price, :in => 10..25
          
          def now
            Time.now
          end

          def file_name
           @file_name ||= "receipt-#{self.created_at.to_i}.txt"
          end

          private

          def add_to_array
            my_array << 1
          end
  
          def save_item
            begin
              File.open(self.file_name, 'w') do |receipt|
                receipt.puts self.created_at
                receipt.puts "price:#{self.price}"
                receipt.puts "paid:#{self.paid}"
              end
            rescue
              return false
            end
            true
          end

          def undo_save
            File.delete(file_name)
          end
        end
        
        item = Item.new
        item.changed?           # => false
        item.created_at         # => 2011-10-23 21:56:07 -0500
        item.created_at         # => 2011-10-23 21:56:08 -0500
        item.active             # => true
        item.paid               # => nil
        item.paid?              # => false
        item.price              # => 10.0
        item.price = '$1,024.00'
        item.price              # => #<BigDecimal:100c989d8,'0.1024E4',9(27)>
        item.changed?           # => true
        item.price_changed?     # => true
        item.changes            # => {"price"=>[#<BigDecimal:7fc61b250da8,'0.1E2',9(27)>, #<BigDecimal:7fc61b1ba600,'0.1024E4',9(27)>]}
        item.my_array           # => []
        item.valid?             # => false
        items.save!             # raises SimpleModel::ValidationError exception
        item.my_array           # => [1]
        item.price = 15 
        item.persisted?         # => false
        item.save               # => true
        item.persisted?         # => true
        item.changed?           # => false
        item.previous_changes   # => {"price"=>[#<BigDecimal:7fc61b1ba600,'0.1024E4',9(27)>, #<BigDecimal:7fc61b1730e8,'0.15E2',9(27)>], "saved"=>[nil, true]} 

### Rails Session Modeling                        
      require 'simple_model'

        class SessionUser < SimpleModel::Base
          has_attributes :permissions, :default => []
          
          # Returns true only if all required permission are set
          def authorized?(*required_permissions)
            (permissions == (required_permissions | permissions))
          end

           #... lots of other handy methods...#
        end

        class ApplicationController < ActionController::Base
          #... omitted for space ...#
          # Initialize, if necessary, and return our session user object
          def session_user
            session[:user] ||= {:permissions => [:foo,:baz]}
            @session_user  ||= SessionUser.new_with_store(session[:user])
          end
          helper_method :session_user

          private

          # redirect if not authorized
          def authorize(*required_permissions)
            redirect_to '/sessions/error' unless session_user.authorized?(*required_permissions)
          end
        end

        class FoosController < ApplicationController
          before_filter do |c| c.send(:authorize,:foo) # Make sure session user has permission
        end
        

## Contributing to simple_model
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Notes

Release 1.2+ no longer create instance variables, just uses the attributes hash as the data store.

## Thanks

Code based on Rails/ActiveRecord and [Appoxy/SimpleRecord](https://github.com/appoxy/simple_record)
