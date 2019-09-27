require 'test_helper'

describe AeEasy::Qa::Validator do
  describe "value tests" do
    it 'should test value equal' do
      data = [{'input' => 'Search', 'type' => 'A'}, {'input' => 'Search1', 'type' => 'A'}, {'input' => 'Search1', 'type' => 'B'}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"input"=>{"value"=>{"equal"=>"Search"}, "required"=>true}}}
      results = qa.validate_external([], 'test')
      assert_equal results, {:errored_items=>[{:failures=>{:input_value=>"fail"}, :item=>{"input"=>"Search1", "type"=>"A"}, "_collection"=>"test"}, {:failures=>{:input_value=>"fail"}, :item=>{"input"=>"Search1", "type"=>"B"}, "_collection"=>"test"}]}
    end

    it 'should test value equal with regular expression' do
      data = [{'input' => 5}, {'input' => 6}, {'input' => 11}]
      qa = AeEasy::Qa::Validator.new(data)
      #validates a single digit as the value
      qa.config = {"individual_validations"=>{"input"=>{"value"=>{"regex"=>"^[0-9]$"}, "required"=>true}}}
      results = qa.validate_external([], 'test')
      assert_equal results, {:errored_items=>[{:failures=>{:input_value=>"fail"}, :item=>{"input"=>11}, "_collection"=>"test"}]}
    end

    it 'should test value equal to day of week with regular expression' do
      data = [{'input' => 'Monday'}, {'input' => 'Tuesday'}, {'input' => "Wedsss"}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"input"=>{"value"=>{"regex"=>"^(Monday|Tuesday|Wednesday|Thursday|Friday)$"}, "required"=>true}}}
      results = qa.validate_external([], 'test')
      assert_equal results, {:errored_items=>[{:failures=>{:input_value=>"fail"}, :item=>{"input"=>"Wedsss"}, "_collection"=>"test"}]}
    end

    it 'should test value equal with if condition' do
      data = [{'input' => 'Search', 'type' => 'A'}, {'input' => 'Search1', 'type' => 'A'}, {'input' => 'Search1', 'type' => 'B'}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"input"=>{"value"=>{"equal"=>"Search", "if"=>{"type"=>{"value"=>{"equal"=>"A"}}}},"required"=>true}}}
      results = qa.validate_external([], 'test')
      assert_equal results, {:errored_items=>[{:failures=>{:input_value=>"fail"}, :item=>{"input"=>"Search1", "type"=>"A"}, "_collection"=>"test"}]}
    end

    it 'should test value equal with if regex condition' do
      data = [{'input' => 'Search', 'type' => 'A'}, {'input' => 'Search1', 'type' => 'A'}, {'input' => 'Search1', 'type' => '123'}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"input"=>{"value"=>{"equal"=>"Search", "if"=>{"type"=>{"value"=>{"regex"=>"[A-Z]"}}}},"required"=>true}}}
      results = qa.validate_external([], 'test')
      assert_equal results, {:errored_items=>[{:failures=>{:input_value=>"fail"}, :item=>{"input"=>"Search1", "type"=>"A"}, "_collection"=>"test"}]}
    end

    it 'should test value less than with if condition' do
      data = [{'input' => 4, 'type' => 'A'}, {'input' => 6, 'type' => 'A'}, {'input' => 10, 'type' => 'B'}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"input"=>{"value"=>{"less_than"=>5, "if"=>{"type"=>{"value"=>{"equal"=>"A"}}}}, "required"=>true}}}
      results = qa.validate_external([], 'test')
      assert_equal results, {:errored_items=>[{:failures=>{:input_value=>"fail"}, :item=>{"input"=>6, "type"=>"A"}, "_collection"=>"test"}]}
    end

    it 'should test value more than with if condition' do
      data = [{'input' => 4, 'type' => 'A'}, {'input' => 6, 'type' => 'A'}, {'input' => 10, 'type' => 'B'}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"input"=>{"value"=>{"greater_than"=>5, "if"=>{"type"=>{"value"=>{"equal"=>"A"}}}}, "required"=>true}}}
      results = qa.validate_external([], 'test')
      assert_equal results, {:errored_items=>[{:failures=>{:input_value=>"fail"}, :item=>{"input"=>4, "type"=>"A"}, "_collection"=>"test"}]}
    end

    it 'should test comparison of multiple values using or' do
      data = [{'input' => 4, 'type' => 'A'}, {'input' => 6, 'type' => 'A'}, {'input' => 10, 'type' => 'B'}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"input"=>{"value"=>{"equal"=>{"or"=>[4,6]}}, "required"=>true}}}
      results = qa.validate_external([], 'test')
      assert_equal results, {:errored_items=>[{:failures=>{:input_value=>"fail"}, :item=>{"input"=>10, "type"=>"B"}, "_collection"=>"test"}]}
    end

    it 'should test comparison of multiple values with if condition' do
      data = [{'input' => 4, 'type' => 'A'}, {'input' => 6, 'type' => 'C'}, {'input' => 10, 'type' => 'B'}, {'input' => 10, 'type' => 'C'}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"input"=>{"value"=>{"equal"=>{"or"=>[4,6]}, "if"=>{"type"=>{"value"=>{"equal"=>"C"}}}}, "required"=>true}}}
      results = qa.validate_external([], 'test')
      assert_equal results, {:errored_items=>[{:failures=>{:input_value=>"fail"}, :item=>{"input"=>10, "type"=>"C"}, "_collection"=>"test"}]}
    end

    it 'should test regex with a regex if statement' do
      data = [{'input' => 4, 'type' => 'a'}, {'input' => 6, 'type' => '99'}, {'input' => 10, 'type' => '99'}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"input"=>{"value"=>{"regex"=>"[A-Z]", "if"=>{"type"=>{"value"=>{"regex"=>"[A-Z]"}}}}, "required"=>true}}}
      results = qa.validate_external([], 'test')
      assert_equal results, {:errored_items=>[{:failures=>{:input_value=>"fail"}, :item=>{"input"=>4, "type"=>"a"}, "_collection"=>"test"}]}
    end

    it 'should test required with an if statement' do
      data = [{'input' => '', 'type' => 'a'}, {'input' => '', 'type' => '99'}, {'input' => 10, 'type' => '99'}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"input"=>{"required"=>true, "if"=>{"type"=>{"value"=>{"regex"=>"[0-9]"}}}}}}
      results = qa.validate_external([], 'test')
      assert_equal results, {:errored_items=>[{:failures=>{:input_required=>"fail"}, :item=>{"input"=>"", "type"=>"99"}, "_collection"=>"test"}]}
    end

    it 'should test required with an if statement that has multiple and conditions' do
      data = [{'input' => '', 'type' => 'a', 'key1' => '6'}, {'input' => '', 'type' => '99', 'key1' => '20'}, {'input' => '', 'type' => '99', 'key1' => '5'}, {'input' => 10, 'type' => '99', 'key1' => '1'}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"input"=>{"required"=>true, "if"=>{"and"=>[{"type"=>{"value"=>{"regex"=>"[0-9]"}}},{"key1"=>{"value"=>{"greater_than"=>"10"}}}]}}}}
      results = qa.validate_external([], 'test')
      assert_equal results, {:errored_items=>[{:failures=>{:input_required=>"fail"}, :item=>{"input"=>"", "type"=>"99", "key1"=>"20"}, "_collection"=>"test"}]}
    end

    it 'should test required with an if statement that has multiple or conditions' do
      data = [{'input' => '', 'type' => 'a', 'key1' => '6'}, {'input' => '', 'type' => 'b', 'key1' => '20'}, {'input' => '', 'type' => '99', 'key1' => '5'}, {'input' => '', 'type' => 'blah', 'key1' => '1'}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"input"=>{"required"=>true, "if"=>{"or"=>[{"type"=>{"value"=>{"regex"=>"[0-9]"}}},{"key1"=>{"value"=>{"less_than"=>"5"}}}]}}}}
      results = qa.validate_external([], 'test')
      assert_equal results, {:errored_items=>[{:failures=>{:input_required=>"fail"}, :item=>{"input"=>"", "type"=>"99", "key1"=>"5"}, "_collection"=>"test"}, {:failures=>{:input_required=>"fail"}, :item=>{"input"=>"", "type"=>"blah", "key1"=>"1"}, "_collection"=>"test"}]}
    end
  end
end
