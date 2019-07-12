require 'test_helper'

describe AeEasy::Qa::Validator do
  describe "type tests" do
    it 'should test required validation' do
      data = [{'rank' => 1}, {'rank' => ''}, {'rank' => 2}, {'rank' => nil}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"rank"=>{"required"=>true}}}
      results = qa.validate_external([], 'test')
      assert_equal results, {:errored_items=>[{:failures=>[{:rank_required=>"fail"}], :item=>{"rank"=>""}, "_collection"=>"test"}, {:failures=>[{:rank_required=>"fail"}], :item=>{"rank"=>nil}, "_collection"=>"test"}]}
    end

    it 'should test length validation' do
      data = [{'upc' => 123400}, {'upc' => 495595}, {'upc' => 249}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"upc"=>{"required"=>true, "length"=>6}}}
      results = qa.validate_external([], 'test')
      assert_equal results, {:errored_items=>[{:failures=>[{:upc_length=>"fail"}], :item=>{"upc"=>249}, "_collection"=>"test"}]}
    end
  end
end
