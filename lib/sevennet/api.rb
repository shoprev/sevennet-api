# coding: utf-8
require 'net/http'
require 'nokogiri'
require 'cgi'
require 'base64'
require 'openssl'

module Sevennet
  class RequestError < StandardError; end
  
  class Api
    SERVICE_URL = 'http://api.7netshopping.jp/ws/affiliate/rest'

    @@options = {
      :Version => "2010-08-01",
      :ResponseFormat => "XML"
    }

    # Default search options
    def self.options
      @@options
    end
    
    # Set default search options
    def self.options=(opts)
      @@options = opts
    end
    
    def self.configure(&proc)
      raise ArgumentError, "Block is required." unless block_given?
      yield @@options
    end

    # Search spc categories by category code.
    def self.get_spc_category(category_code, opts = {})
      opts[:operation] = 'GetSpcCategory'
      opts[:CategoryCode] = category_code

      self.send_request(opts)
    end

    # Search spc shops with search terms.
    def self.search_spc_shop(terms, opts = {})
      opts[:operation] = 'SearchSpcShop'
      opts[:KeywordIn] = CGI.escape(terms.to_s)

      self.send_request(opts)
    end
    
    # Search categories by category code.
    def self.get_shopping_category(category_code, opts = {})
      opts[:operation] = 'GetShoppingCategory'
      opts[:CategoryCode] = category_code

      self.send_request(opts)
    end
    
    # Search products with search terms.
    def self.search_product(terms, opts = {})
      if terms.to_s.empty? && (options[:CategoryCode].to_s.empty? && opts[:CategoryCode].to_s.empty?)
        raise ArgumentError, "CategoryCode or KeywordIn is required."
      end

      opts[:operation] = 'SearchProduct'
      opts[:KeywordIn] = CGI.escape(terms.to_s)

      self.send_request(opts)
    end

    # Search products by category code.
    def self.search_ranking(category_code, opts = {})
      opts[:operation] = 'SearchRanking'
      opts[:CategoryCode] = category_code
      
      raise ArgumentError, "CategoryCode is required." if category_code.to_s.empty?
      
      self.send_request(opts)
    end

    # Search a product reviews with product code.
    # For other search type other than keywords, please specify :type => 'ProductStandardCode'.
    def self.search_product_review(product_code, opts = {})
      opts[:operation] = 'SearchProductReview'

      type = (opts.delete(:type) || options.delete(:type))
      if type
        opts[type.to_sym] = product_code
      else 
        opts[:ProductCode] = product_code
      end

      raise ArgumentError, "ProductCode is required." if product_code.to_s.empty?
      
      self.send_request(opts)
    end

    # Search products by contents.
    def self.search_content_match_product(content, opts = {})

      raise ArgumentError, "Content is required." if content.to_s.empty?

      opts[:operation] = 'SearchContentMatchProduct'
      opts[:Content] = CGI.escape(content)

      self.send_request(opts)
    end    
    
    # Search products by category code and contents.
    def self.search_content_match_ranking(category_code, content, opts = {})

      raise ArgumentError, "TopCategoryCode and Content is required." if content.to_s.empty? || category_code.to_s.empty?

      opts[:operation] = 'SearchContentMatchRanking'
      opts[:Content] = CGI.escape(content)
      opts[:TopCategoryCode] = category_code

      
      self.send_request(opts)
    end    

    # Generic send request to API REST service. You have to specify the :operation parameter.
    def self.send_request(opts)
      opts = self.options.merge(opts) if self.options
      
      # Include other required options
      opts[:Timestamp] = Time.now.strftime('%Y-%m-%dT%XZ')

      request_url = prepare_url(opts)

      res = Net::HTTP.get_response(URI::parse(request_url))
      unless res.kind_of? Net::HTTPSuccess
        raise Sevennet::RequestError, "HTTP Response: #{res.code} #{res.message}"
      end
      Response.new(res.body)
    end
    
    # Response object returned after a REST call to sevennet api.
    class Response
      
      # XML input is in string format
      def initialize(xml)
        @doc = Nokogiri::XML(xml, nil, 'UTF-8')
        @doc.remove_namespaces!
      end

      # Return Nokogiri::XML::Document object.
      def doc
        @doc
      end

      # Return true if response has an error.
      def has_error?
        !(error.nil? || error.empty?)
      end

      # Return error message.
      def error
        Element.get(@doc, "//ApiErrorMessage")
      end
      
      # Return error code
      def error_code
        Element.get(@doc, "//ApiErrorStatus")
      end
      
      # Return an array of Sevennet::Element category objects.
      def categories
        @categories ||= (@doc/"Category").collect { |it| Element.new(it) }
      end

      # Return an array of Sevennet::Element shop objects.
      def shops
        @shops ||= (@doc/"SpcShop").collect { |it| Element.new(it) }
      end

      # Return an array of Sevennet::Element product objects.
      def products
        @products ||= (@doc/"Product").collect { |it| Element.new(it) }
      end

      # Return an array of Sevennet::Element review objects.
      def reviews
        @reviews ||= (@doc/"ProductReview").collect { |it| Element.new(it) }
      end

      # Return total results.
      def total_amount
        @total_amount ||= Element.get(@doc, "//TotalAmount").to_i
      end
    end

    private 
      def self.prepare_url(opts)
        secret_key = opts.delete(:APISecretKey)
        operation = opts.delete(:operation)
        request_url = "#{SERVICE_URL}/#{operation}"
        
        qs = []
        
        opts = opts.collect do |a,b| 
          [a.to_s, b.to_s] 
        end
        
        opts = opts.sort do |c,d| 
          c[0].to_s <=> d[0].to_s
        end
        
        opts.each do |e| 
          next if e[1].empty? || e[1].nil?
          qs << "#{e[0]}=#{e[1]}"
        end
        
        request_to_sign ="GET|#{request_url}|#{qs.join('|')}"
        signature = "&Signature=#{sign_request(request_to_sign, secret_key)}"
        "#{request_url}?#{qs.join('&')}#{signature}"
      end

      def self.sign_request(url, key)
        signature = OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new, key, CGI.escape(url))
        signature = Base64.encode64(signature).chomp
        signature
      end
  end

  # Internal wrapper class to provide convenient method to access Nokogiri element value.
  class Element
    class << self
      # Return the text value of an element.
      def get(element, path='.')
        return unless element
        result = element.at_xpath(path)
        result = result.inner_html if result
        result
      end
    
      # Return an unescaped text value of an element.
      def get_unescaped(element, path='.')
        result = self.get(element, path)
        CGI.unescape(result) if result
      end

      # Return an array of values based on the given path.
      def get_array(element, path='.')
        return unless element
      
        result = element/path
        if (result.is_a? Nokogiri::XML::NodeSet) || (result.is_a? Array)
          result.collect { |item| self.get(item) }
        else
          [self.get(result)]
        end
      end

      # Return child element text values of the given path.
      def get_hash(element, path='.')
        return unless element
    
        result = element.at_xpath(path)
        if result
          hash = {}
          result = result.children
          result.each do |item|
            hash[item.name] = item.inner_html
          end 
          hash
        end
      end
    end
    
    # Pass Nokogiri::XML::Element object
    def initialize(element)
      @element = element
    end

    # Returns Nokogiri::XML::Element object    
    def elem
      @element
    end
    
    # Returns a Nokogiri::XML::NodeSet of elements matching the given path. Example: element/"author".
    def /(path)
      elements = @element/path
      return nil if elements.size == 0
      elements
    end

    # Return an array of Sevennet::Element matching the given path
    def get_elements(path)
      elements = self./(path)
      return unless elements
      elements = elements.map{|element| Element.new(element)}
    end
    
    # Similar with search_and_convert but always return first element if more than one elements found
    def get_element(path)
      elements = get_elements(path)
      elements[0] if elements
    end

    # Get the text value of the given path, leave empty to retrieve current element value.
    def get(path='.')
      Element.get(@element, path)
    end
    
    # Get the unescaped HTML text of the given path.
    def get_unescaped(path='.')
      Element.get_unescaped(@element, path)
    end
    
    # Get the array values of the given path.
    def get_array(path='.')
      Element.get_array(@element, path)
    end

    # Get the children element text values in hash format with the element names as the hash keys.
    def get_hash(path='.')
      Element.get_hash(@element, path)
    end
    
    def attributes
      return unless self.elem
      self.elem.attributes
    end
    
    def to_s
      elem.to_s if elem
    end
  end
end