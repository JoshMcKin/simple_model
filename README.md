# SimpleModel
A collection of convenience methods for building table-less models. If ActiveModel
gem is installed, SimpleModel::Based will include ActiveModel::Validations,
include ActiveModel::Conversion and extend ActiveModel::Naming. If ActiveModel
gem is not available, SimpleModel::Base defaults to its own built-in Error and Validation modules.

## Installation


SimpleModel is available through [Rubygems](http://rubygems.org/gems/simple_model) and can be installed via:

    $ gem install simple_model

## Usage
### Basic
      require 'simple_model'

        class Item < SimpleModel::Base
          save :save_item, :rollback => :undo_save
          has_booleans :active, :default => true
          has_booleans :paid
          has_currency :price, :default => 10.0
          has_times :created_at, :default => :now
          validates_inclusion_of :price, :in => 10..25
          
          def now
            Time.now
          end

          def file_name
           @file_name ||= "receipt-#{self.created_at.to_i}.txt"
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
        item.created_at # => 2011-10-23 21:56:07 -0500
        item.created_at # => 2011-10-23 21:56:08 -0500
        item.active     # => true
        item.paid       # => nil
        item.paid?      # => false
        item.price      # => 10.0
        item.price = '$1,024.00'
        item.price      # => #<BigDecimal:100c989d8,'0.1024E4',9(27)>
        item.valid?     # => false
        item.price = 15 
        item.save       # => true
                        


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
