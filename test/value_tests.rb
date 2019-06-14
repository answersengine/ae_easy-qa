require 'test_helper'

describe AeEasy::Qa::Validator do
  describe "value tests" do
    it 'should test value equal' do
      data = [{'input' => 'Search', 'type' => 'A'}, {'input' => 'Search1', 'type' => 'A'}, {'input' => 'Search1', 'type' => 'B'}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"input"=>{"value"=>{"equal"=>"Search"}, "required"=>true}}}
      results = qa.validate_external
      assert_equal results, {:errored_items=>[{:failures=>[{:input_value=>"fail"}], :item=>{"input"=>"Search1", "type"=>"A"}}, {:failures=>[{:input_value=>"fail"}], :item=>{"input"=>"Search1", "type"=>"B"}}]}
    end
    it 'should test value equal with if condition' do
      data = [{'input' => 'Search', 'type' => 'A'}, {'input' => 'Search1', 'type' => 'A'}, {'input' => 'Search1', 'type' => 'B'}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"input"=>{"value"=>{"equal"=>"Search", "if"=>{"type"=>{"value"=>"A"}}},"required"=>true}}}
      results = qa.validate_external
      assert_equal results, {:errored_items=>[{:failures=>[{:input_value=>"fail"}], :item=>{"input"=>"Search1", "type"=>"A"}}]}
    end

    it 'should test value less than with if condition' do
      data = [{'input' => 4, 'type' => 'A'}, {'input' => 6, 'type' => 'A'}, {'input' => 10, 'type' => 'B'}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"input"=>{"value"=>{"less_than"=>5, "if"=>{"type"=>{"value"=>"A"}}}, "required"=>true}}}
      results = qa.validate_external
      assert_equal results, {:errored_items=>[{:failures=>[{:input_value=>"fail"}], :item=>{"input"=>6, "type"=>"A"}}]}
    end

    it 'should test value more than with if condition' do
      data = [{'input' => 4, 'type' => 'A'}, {'input' => 6, 'type' => 'A'}, {'input' => 10, 'type' => 'B'}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"input"=>{"value"=>{"greater_than"=>5, "if"=>{"type"=>{"value"=>"A"}}}, "required"=>true}}}
      results = qa.validate_external
      assert_equal results, {:errored_items=>[{:failures=>[{:input_value=>"fail"}], :item=>{"input"=>4, "type"=>"A"}}]}
    end

    it 'should test comparison of multiple values using or' do
      data = [{'input' => 4, 'type' => 'A'}, {'input' => 6, 'type' => 'A'}, {'input' => 10, 'type' => 'B'}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"input"=>{"value"=>{"equal"=>{"or"=>[4,6]}}, "required"=>true}}}
      results = qa.validate_external
      assert_equal results, {:errored_items=>[{:failures=>[{:input_value=>"fail"}], :item=>{"input"=>10, "type"=>"B"}}]}
    end

    it 'should test comparison of multiple values with if condition' do
      data = [{'input' => 4, 'type' => 'A'}, {'input' => 6, 'type' => 'C'}, {'input' => 10, 'type' => 'B'}, {'input' => 10, 'type' => 'C'}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"input"=>{"value"=>{"equal"=>{"or"=>[4,6]}, "if"=>{"type"=>{"value"=>"C"}}}, "required"=>true}}}
      results = qa.validate_external
      assert_equal results, {:errored_items=>[{:failures=>[{:input_value=>"fail"}], :item=>{"input"=>10, "type"=>"C"}}]}
    end
  end
end
