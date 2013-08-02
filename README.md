# Sevennet::Api

Generic 7netshopping Ruby API using Nokogiri. Uses Response and Element wrapper classes for easy access to the REST API XML output.

## Installation

Add this line to your application's Gemfile:

    gem 'sevennet-api'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sevennet-api

## Usage

    require 'sevennet/api'

    Sevennet::Api.configure do |options|
      options[:ApiUserId] = 'your api user id'
      options[:APISecretKey] = 'your api secret key'
    end

    # GetShoppingCategory
    res = Sevennet::Api.get_shopping_category('') # root category
    res = Sevennet::Api.get_shopping_category('books') # books category
    res.categories.each do |category|
      children = category.get('ChildCategory')
      children.each do |child|
        code = child.get('CategoryCode')
        ...
      end
    end

    # SearchProduct
    res = Sevennet::Api.search_product('ruby', {:ShoppingSortOrder => 'reviews'}) # keyword match
    res = Sevennet::Api.search_product('', {:CategoryCode = 'books'}) # category match
    res = Sevennet::Api.search_product('ruby', {:CategoryCode = 'books'}) # keyword and category match
    res.products.each do |product|
      code = product.get('ProductCode')
      ...
    end

    # SearchRanking
    res = Sevennet::Api.search_ranking('books', {:GenerationCond => 10, :SexCond => 'male'})
    res.products.each do |product|
      code = product.get('ProductCode')
      ...
    end

    # SearchProductReview
    res = Sevennet::Api.search_product_review('2110150300') # ProductCode
    res = Sevennet::Api.search_product_review('21-101-503-00',:type => 'ProductStandardCode') # ISBN JAN etc
    res.reviews.each do |review|
      title = review.get('CommentTitle')
      ...
    end

    # GetSpcCategory
    res = Sevennet::Api.get_spc_category('') # root category
    res = Sevennet::Api.get_spc_category('home') # home category
    res.categories.each do |category|
      children = category.get('ChildCategory')
      children.each do |child|
        code = child.get('CategoryCode')
        ...
      end
    end

    # SearchSpcShop
    res = Sevennet::Api.search_spc_shop('', {:SpcSortOrder => 'name') # all
    res = Sevennet::Api.search_spc_shop('ruby', {:SpcSortOrder => 'name') # keyword match
    res.shops.each do |shop|
      id = shop.get('SpcShopId')
      ...
    end

    # some common response object methods
    res.has_error?            # return true if there is an error
    res.error                 # return error message if there is any
    res.total_amount          # return total results

    # Extend Sevennet::Api, replace 'other_operation' with the appropriate name
    module Sevennet
      class Api
        def self.other_operation(item_id, opts={})
          opts[:operation] = '[other valid operation supported by 7netshopping API]'

          # setting default option value
          opts[:item_id] = item_id

          self.send_request(opts)
        end
      end
    end
    
    Sevennet::Api.other_operation('[item_id]', :param1 => 'abc', :param2 => 'xyz')

Refer to 7netshopping API documentation for more information on other valid operations, request parameters and the XML response output: http://www.7netshopping.jp/

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
