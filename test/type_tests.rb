require 'test_helper'

describe AeEasy::Qa::Validator do
  describe "type tests" do
    it 'should test required validation' do
      data = [{'rank' => 1}, {'rank' => ''}, {'rank' => 2}, {'rank' => nil}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"rank"=>{"required"=>true}}}
      results = qa.validate_external
      assert_equal results, {:errored_items=>[{:failures=>[{:rank_required=>"fail"}], :item=>{"rank"=>""}}, {:failures=>[{:rank_required=>"fail"}], :item=>{"rank"=>nil}}]}
    end

    it 'should test required validation with failed type validation' do
      data = [{'rank' => nil}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"rank"=>{"required"=>true, "type"=>"Integer"}}}
      results = qa.validate_external
      assert_equal results, {:errored_items=>[{:failures=>[{:rank_required=>"fail"}], :item=>{"rank"=>nil}}]}
    end

    it 'should test integer type validation' do
      data = [{'rank' => '1'}, {'rank' => '1 '}, {'rank' => 1}, {'rank' => 'test'},
              {'rank' => '1,500'}, {'rank' => '500.04'}, {'rank' => '1,500.04'},
              {'rank' => '1/5'}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"rank"=>{"type"=>"Integer", "required"=>true}}}
      results = qa.validate_external
      assert_equal results, {:errored_items=>[{:failures=>[{:rank_type=>"fail"}], :item=>{"rank"=>"test"}},
                                              {:failures=>[{:rank_type=>"fail"}], :item=>{"rank"=>"1/5"}}]}
    end

    it 'should test string type validation' do
      data = [{'rank' => 1}, {'rank' => 'test'}, {'rank' => nil}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"rank"=>{"type"=>"String", "required"=>true}}}
      results = qa.validate_external
      assert_equal results, {:errored_items=>[{:failures=>[{:rank_type=>"fail"}], :item=>{"rank"=>1}}, {:failures=>[{:rank_required=>"fail"}], :item=>{"rank"=>nil}}]}
    end

    it 'should test date type validation' do
      data = [{'created_at' => '3/28/2018 10:12'}, {'created_at' => '3/28/2018'}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"created_at"=>{"type"=>"Date","format"=>"%-m/%-d/%Y %H:%M", "required"=>true}}}
      results = qa.validate_external
      assert_equal results, {:errored_items=>[{:failures=>[{:created_at_type=>"fail"}], :item=>{"created_at"=>"3/28/2018"}}]}
    end

    it 'should test url type validation' do
      data = [{'url' => 'blah'}, {'url' => 'http://test.com'}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"url"=>{"type"=>"Url", "required"=>true}}}
      results = qa.validate_external
      assert_equal results, {:errored_items=>[{:failures=>[{:url_type=>"fail"}], :item=>{"url"=>"blah"}}]}
    end

    it 'should test url and date type validation' do
      data = [{'url' => 'blah', 'created_at' => '3/28/2018'}, {'url' => 'http://test.com', 'created_at' => '3/28/2018 10:12'}]
      qa = AeEasy::Qa::Validator.new(data)
      qa.config = {"individual_validations"=>{"url"=>{"type"=>"Url", "required"=>true}, "created_at"=>{"type"=>"Date","format"=>"%-m/%-d/%Y %H:%M", "required"=>true}}}
      results = qa.validate_external
      assert_equal results, {:errored_items=>[{:failures=>[{:url_type=>"fail"}, {:created_at_type=>"fail"}], :item=>{"url"=>"blah", "created_at"=>"3/28/2018"}}]}
    end
  end
end
