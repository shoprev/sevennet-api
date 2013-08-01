# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

share_examples_for 'found products search keyword or options' do
  subject { response }
  its(:total_amount) { should > 0 }
  its(:doc) { should be_kind_of Nokogiri::XML::Document }
  it { should_not be_has_error }
  context 'products.first' do
    subject { response.products.first/"ProductCode" }
    it { should_not be_empty }
  end
end

share_examples_for 'not found products search keyword or options' do
  subject { response }
  its(:total_amount) { should == 0 }
  its(:doc) { should be_kind_of Nokogiri::XML::Document }
  its('products') { should == [] }
  it { should_not be_has_error }
end

share_examples_for 'category common test' do
  subject { response }
  its(:total_amount) { should == 0 }
  its(:doc) { should be_kind_of Nokogiri::XML::Document }
  its('categories.first') { should be_kind_of Sevennet::Element }
  it { should_not be_has_error }
  context 'child category' do
    subject { response.categories.first/"ChildCategory" }
    it { should_not be_empty }
  end
end

describe "Sevennet::Api.search_content_match_ranking" do
  let(:response) {
    VCR.use_cassette('search_content_match_ranking_' + top_category_code.to_s + '_' + content.to_s + '_' + opts.to_s) do
      Sevennet::Api.search_content_match_ranking(top_category_code,content)
    end
  }
  let(:options) {
    Sevennet::Api.configure do |options|
      options[:StartIndex] = 1
      options[:ResultAmount] = 5
    end
  }
  let(:no_option) {
    Sevennet::Api.configure do |options|
      options[:StartIndex] = nil
      options[:ResultAmount] = nil
    end
  }

#  context 'search keyword and options' do
#    let(:top_category_code) { 'magazine' }
#    let(:content) { 'focus' }
#    let(:opts) { options }
#    it_should_behave_like 'found products search keyword or options'
#  end

#  context 'search keyword without options' do
#    let(:top_category_code) { 'magazine' }
#    let(:content) { 'focus' }
#    let(:opts) { no_option }
#    it_should_behave_like 'found products search keyword or options'
#  end

  context 'search options without keyword' do
    let(:top_category_code) { 'magazine' }
    let(:content) { nil }
    let(:opts) { options }
    it { lambda{ response }.should raise_error( ArgumentError, "TopCategoryCode and Content is required.") }
  end

  context 'search without keyword and options' do
    let(:top_category_code) { 'magazine' }
    let(:content) { nil }
    let(:opts) { no_option }
    it { lambda{ response }.should raise_error( ArgumentError, "TopCategoryCode and Content is required.") }
  end

  context 'not found search keyword and options' do
    let(:top_category_code) { 'magazine' }
    let(:content) { 'focus friday' }
    let(:opts) { options }
    it_should_behave_like 'not found products search keyword or options'
  end

  context 'not found search keyword without options' do
    let(:top_category_code) { 'magazine' }
    let(:content) { 'focus friday' }
    let(:opts) { no_option }
    it_should_behave_like 'not found products search keyword or options'
  end
end

describe "Sevennet::Api.search_content_match_product" do
  let(:response) {
    VCR.use_cassette('search_content_match_product_' + content.to_s + '_' + opts.to_s) do
      Sevennet::Api.search_content_match_product(content)
    end
  }
  let(:options) {
    Sevennet::Api.configure do |options|
      options[:StartIndex] = 1
      options[:ResultAmount] = 5
    end
  }
  let(:no_option) {
    Sevennet::Api.configure do |options|
      options[:StartIndex] = nil
      options[:ResultAmount] = nil
    end
  }

  context 'search keyword and options' do
    let(:content) { 'ruby perl javascript' }
    let(:opts) { options }
    it_should_behave_like 'found products search keyword or options'
  end

  context 'search keyword without options' do
    let(:content) { 'ruby perl javascript' }
    let(:opts) { no_option }
    it_should_behave_like 'found products search keyword or options'
  end

  context 'search options without keyword' do
    let(:content) { nil }
    let(:opts) { options }
    it { lambda{ response }.should raise_error( ArgumentError, "Content is required.") }
  end

  context 'search without keyword and options' do
    let(:content) { nil }
    let(:opts) { no_option }
    it { lambda{ response }.should raise_error( ArgumentError, "Content is required.") }
  end

  context 'not found search keyword and options' do
    let(:content) { 'titanium coffeescript' }
    let(:opts) { options }
    it_should_behave_like 'not found products search keyword or options'
  end

  context 'not found search keyword without options' do
    let(:content) { 'titanium coffeescript' }
    let(:opts) { no_option }
    it_should_behave_like 'not found products search keyword or options'
  end
end

describe "Sevennet::Api.search_product_review" do
  let(:response) {
    VCR.use_cassette('search_product_review_' + product_code.to_s + '_' + opts.to_s) do
      Sevennet::Api.search_product_review(product_code)
    end
  }
  let(:options) {
    Sevennet::Api.configure do |options|
      options[:StartIndex] = 1
      options[:ResultAmount] = 5
      options[:type] = 'ProductStandardCode'
    end
  }
  let(:no_option) {
    Sevennet::Api.configure do |options|
      options[:StartIndex] = nil
      options[:ResultAmount] = nil
      options[:type] = nil
    end
  }

  share_examples_for 'found review search keyword or options' do
    subject { response }
    its(:total_amount) { should > 0 }
    its(:doc) { should be_kind_of Nokogiri::XML::Document }
    it { should_not be_has_error }
    context 'reviews.first' do
      subject { response.reviews.first/"CommentTitle" }
      it { should_not be_empty }
    end
  end

  share_examples_for 'not found review search keyword or options' do
    subject { response }
    its(:total_amount) { should == 0 }
    its(:doc) { should be_kind_of Nokogiri::XML::Document }
    its('reviews') { should == [] }
    it { should_not be_has_error }
  end

  context 'search keyword and options' do
    let(:product_code) { '4901901397298' }
    let(:opts) { options }
    it_should_behave_like 'found review search keyword or options'
  end

  context 'search keyword without options' do
    let(:product_code) { '2110150300' }
    let(:opts) { no_option }
    it_should_behave_like 'found review search keyword or options'
  end

  context 'search options without keyword' do
    let(:product_code) { nil }
    let(:opts) { options }
    it { lambda{ response }.should raise_error( ArgumentError, "ProductCode is required.") }
  end

  context 'search without keyword and options' do
    let(:product_code) { nil }
    let(:opts) { no_option }
    it { lambda{ response }.should raise_error( ArgumentError, "ProductCode is required.") }
  end

  context 'not found search keyword and options' do
    let(:product_code) { '978-4-04-110518-4' }
    let(:opts) { options }
    it_should_behave_like 'not found review search keyword or options'
  end

  context 'not found search keyword without options' do
    let(:product_code) { '1106317843' }
    let(:opts) { no_option }
    it_should_behave_like 'not found review search keyword or options'
  end
end

describe "Sevennet::Api.search_ranking" do
  let(:response) {
    VCR.use_cassette('search_ranking_' + category_code.to_s + '_' + opts.to_s) do
      Sevennet::Api.search_ranking(category_code)
    end
  }
  let(:options) {
    Sevennet::Api.configure do |options|
      options[:StartIndex] = 1
      options[:ResultAmount] = 5
      options[:TermCond] = 'last1w'
    end
  }
  let(:no_option) {
    Sevennet::Api.configure do |options|
      options[:StartIndex] = nil
      options[:ResultAmount] = nil
      options[:TermCond] = nil
    end
  }

  context 'search keyword and options' do
    let(:category_code) { 'cd' }
    let(:opts) { options }
    it_should_behave_like 'found products search keyword or options'
  end

  context 'search keyword without options' do
    let(:category_code) { 'cd' }
    let(:opts) { no_option }
    it_should_behave_like 'found products search keyword or options'
  end

  context 'search options without keyword' do
    let(:category_code) { nil }
    let(:opts) { options }
    it { lambda{ response }.should raise_error( ArgumentError, "CategoryCode is required.") }
  end

  context 'search without keyword and options' do
    let(:category_code) { nil }
    let(:opts) { no_option }
    it { lambda{ response }.should raise_error( ArgumentError, "CategoryCode is required.") }
  end

  context 'not found search keyword and options' do
    let(:category_code) { 'rubyssssss' }
    let(:opts) { options }
    it_should_behave_like 'not found products search keyword or options'
  end

  context 'not found search keyword without options' do
    let(:category_code) { 'rubyssssss' }
    let(:opts) { no_option }
    it_should_behave_like 'not found products search keyword or options'
  end
end

describe "Sevennet::Api.search_product" do
  let(:response) {
    VCR.use_cassette('search_product_' + terms.to_s + '_' + opts.to_s) do
      Sevennet::Api.search_product(terms)
    end
  }
  let(:options) {
    Sevennet::Api.configure do |options|
      options[:StartIndex] = 1
      options[:ResultAmount] = 5
      options[:CategoryCode] = 'cd'
    end
  }
  let(:no_option) {
    Sevennet::Api.configure do |options|
      options[:StartIndex] = nil
      options[:ResultAmount] = nil
      options[:CategoryCode] = nil
    end
  }

  context 'search keyword and options' do
    let(:terms) { 'au' }
    let(:opts) { options }
    it_should_behave_like 'found products search keyword or options'
  end

  context 'search keyword without options' do
    let(:terms) { 'au' }
    let(:opts) { no_option }
    it_should_behave_like 'found products search keyword or options'
  end

  context 'search options without keyword' do
    let(:terms) { nil }
    let(:opts) { options }
    it_should_behave_like 'found products search keyword or options'
  end

  context 'search without keyword and options' do
    let(:terms) { nil }
    let(:opts) { no_option }
    it { lambda{response}.should raise_error( ArgumentError, "CategoryCode or KeywordIn is required.") }
  end

  context 'not found search keyword and options' do
    let(:terms) { 'rubyssssss' }
    let(:opts) { options }
    it_should_behave_like 'not found products search keyword or options'
  end

  context 'not found search keyword without options' do
    let(:terms) { 'rubyssssss' }
    let(:opts) { no_option }
    it_should_behave_like 'not found products search keyword or options'
  end
end

describe "Sevennet::Api.search_spc_shop" do
  let(:response) {
    VCR.use_cassette('search_spc_shop_' + terms.to_s + '_' + opts.to_s) do
      Sevennet::Api.search_spc_shop(terms)
    end
  }
  let(:options) {
    Sevennet::Api.configure do |options|
      options[:StartIndex] = 1
      options[:ResultAmount] = 5
      options[:SpcSortOrder] = 'name'
    end
  }
  let(:no_option) {
    Sevennet::Api.configure do |options|
      options[:StartIndex] = nil
      options[:ResultAmount] = nil
      options[:SpcSortOrder] = nil
    end
  }
  share_examples_for 'found spc shop search keyword or options' do
    subject { response }
    its(:total_amount) { should > 0 }
    its(:doc) { should be_kind_of Nokogiri::XML::Document }
    it { should_not be_has_error }
    context 'shops.first' do
      subject { response.shops.first/"SpcShopId" }
      it { should_not be_empty }
    end
  end

  share_examples_for 'not found spc shop search keyword or options' do
    subject { response }
    its(:total_amount) { should == 0 }
    its(:doc) { should be_kind_of Nokogiri::XML::Document }
    its('shops') { should == [] }
    it { should_not be_has_error }
  end

  context 'search keyword and options' do
    let(:terms) { 'au' }
    let(:opts) { options }
    it_should_behave_like 'found spc shop search keyword or options'
  end

  context 'search keyword without options' do
    let(:terms) { 'au' }
    let(:opts) { no_option }
    it_should_behave_like 'found spc shop search keyword or options'
  end

  context 'search options without keyword' do
    let(:terms) { nil }
    let(:opts) { options }
    it_should_behave_like 'found spc shop search keyword or options'
  end

  context 'search without keyword and options' do
    let(:terms) { nil }
    let(:opts) { no_option }
    it_should_behave_like 'found spc shop search keyword or options'
  end

  context 'not found search keyword and options' do
    let(:terms) { 'ruby' }
    let(:opts) { options }
    it_should_behave_like 'not found spc shop search keyword or options'
  end

  context 'not found search keyword without options' do
    let(:terms) { 'ruby' }
    let(:opts) { no_option }
    it_should_behave_like 'not found spc shop search keyword or options'
  end
end

describe "Sevennet::Api.get_shopping_category" do
  let(:response) {
    VCR.use_cassette('get_shopping_category_' + category_code.to_s) do
      Sevennet::Api.get_shopping_category(category_code)
    end
  }

  context 'root category' do
    let(:category_code) { '' }
    it_should_behave_like 'category common test'
  end

  context 'level 1 category' do
    let(:category_code) { 'books' }
    it_should_behave_like 'category common test'
  end

  context 'level 2 category' do
    let(:category_code) { 'literature' }
    it_should_behave_like 'category common test'
  end

  context 'wrong category code' do
    let(:category_code) { '9989989898989898' }
    subject { response }
    its(:total_amount) { should == 0 }
    its(:doc) { should be_kind_of Nokogiri::XML::Document }
    its('categories.first') { should be_nil }
    it { should_not be_has_error }
  end
end

describe "Sevennet::Api.get_spc_category" do
  let(:response) {
    VCR.use_cassette('get_spc_category_' + category_code.to_s) do
      Sevennet::Api.get_spc_category(category_code)
    end
  }

  context 'root category' do
    let(:category_code) { '' }
    it_should_behave_like 'category common test'
  end

  context 'level 1 category' do
    let(:category_code) { 'books' }
    it_should_behave_like 'category common test'
  end

  context 'level 2 category' do
    let(:category_code) { 'literature' }
    it_should_behave_like 'category common test'
  end

  context 'wrong category code' do
    let(:category_code) { '9989989898989898' }
    subject { response }
    its(:total_amount) { should == 0 }
    its(:doc) { should be_kind_of Nokogiri::XML::Document }
    its('categories.first') { should be_nil }
    it { should_not be_has_error }
  end
end