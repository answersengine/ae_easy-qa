require 'test_helper'

describe AeEasy::Qa::Validator do
  describe "error tests" do
    it 'should test unknown validation' do
      data = [{'url' => 'blah', 'created_at' => '3/28/2018'}, {'url' => 'http://test.com', 'created_at' => '3/28/2018 10:12'}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"url"=>{"typeee"=>"Url", "required"=>true}}}
      results = qa.validate_external([], 'test')
      assert_nil results
    end

    it 'should test unknown validation type' do
      data = [{'url' => 'blah', 'created_at' => '3/28/2018'}, {'url' => 'http://test.com', 'created_at' => '3/28/2018 10:12'}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"url"=>{"type"=>"blah", "required"=>true}}}
      results = qa.validate_external([], 'test')
      assert_nil results
    end

    it 'should test missing date format' do
      data = [{'created_at' => '3/28/2018 10:12'}, {'created_at' => '3/28/2018'}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"created_at"=>{"type"=>"Date", "required"=>true}}}
      results = qa.validate_external([], 'test')
      assert_nil results
    end
  end
end
