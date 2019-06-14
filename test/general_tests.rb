require 'test_helper'

describe AeEasy::Qa::Validator do
  describe "type tests" do
    it 'should test required validation' do
      data = [{'rank' => 1}, {'rank' => ''}, {'rank' => 2}, {'rank' => nil}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"rank"=>{"required"=>true}}}
      results = qa.validate_external
      assert_equal results, {:errored_items=>[{:failures=>[{:rank=>"required"}], :data=>{"rank"=>""}}, {:failures=>[{:rank=>"required"}], :data=>{"rank"=>nil}}]}
    end

    it 'should test length validation' do
      data = [{'upc' => 123400}, {'upc' => 495595}, {'upc' => 249}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"upc"=>{"required"=>true, "length"=>6}}}
      results = qa.validate_external
      assert_equal results, {:errored_items=>[{:failures=>[{:upc=>"length"}], :data=>{"upc"=>249}}]}
    end
  end
end
