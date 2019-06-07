require 'test_helper'

describe AeEasy::Qa::Validate do
  describe "type tests" do
    it 'should test required validation' do
      data = [{'rank' => 1}, {'rank' => ''}, {'rank' => 2}, {'rank' => nil}]
      qa = AeEasy::Qa::Validate.new(data)
      qa.rules = {"individual_validations"=>{"rank"=>{"required"=>true}}}
      results = qa.run
      assert_equal results, {:errored_items=>[{:failures=>[{:rank=>"required"}], :data=>{"rank"=>""}}, {:failures=>[{:rank=>"required"}], :data=>{"rank"=>nil}}]}
    end

    it 'should test integer type validation' do
      data = [{'rank' => '1'}, {'rank' => '1 '}, {'rank' => 1}, {'rank' => 'test'}, ]
      qa = AeEasy::Qa::Validate.new(data)
      qa.rules = {"individual_validations"=>{"rank"=>{"type"=>"Integer", "required"=>true}}}
      results = qa.run
      assert_equal results, {:errored_items=>[{:failures=>[{:rank=>"type"}], :data=>{"rank"=>"test"}}]}
    end

    it 'should test string type validation' do
      data = [{'rank' => 1}, {'rank' => 'test'}, {'rank' => nil}]
      qa = AeEasy::Qa::Validate.new(data)
      qa.rules = {"individual_validations"=>{"rank"=>{"type"=>"String", "required"=>true}}}
      results = qa.run
      assert_equal results, {:errored_items=>[{:failures=>[{:rank=>"type"}], :data=>{"rank"=>1}}, {:failures=>[{:rank=>"type"}, {:rank=>"required"}], :data=>{"rank"=>nil}}]}
    end

    it 'should test date type validation' do
      data = [{'created_at' => '3/28/2018 10:12'}, {'created_at' => '3/28/2018'}]
      qa = AeEasy::Qa::Validate.new(data)
      qa.rules = {"individual_validations"=>{"created_at"=>{"type"=>"Date","format"=>"%-m/%-d/%Y %H:%M", "required"=>true}}}
      results = qa.run
      assert_equal results, {:errored_items=>[{:failures=>[{:created_at=>"type"}], :data=>{"created_at"=>"3/28/2018"}}]}
    end

    it 'should test url type validation' do
      data = [{'url' => 'blah'}, {'url' => 'http://test.com'}]
      qa = AeEasy::Qa::Validate.new(data)
      qa.rules = {"individual_validations"=>{"url"=>{"type"=>"Url", "required"=>true}}}
      results = qa.run
      assert_equal results, {:errored_items=>[{:failures=>[{:url=>"type"}], :data=>{"url"=>"blah"}}]}
    end

    it 'should test url and date type validation' do
      data = [{'url' => 'blah', 'created_at' => '3/28/2018'}, {'url' => 'http://test.com', 'created_at' => '3/28/2018 10:12'}]
      qa = AeEasy::Qa::Validate.new(data)
      qa.rules = {"individual_validations"=>{"url"=>{"type"=>"Url", "required"=>true}, "created_at"=>{"type"=>"Date","format"=>"%-m/%-d/%Y %H:%M", "required"=>true}}}
      results = qa.run
      assert_equal results, {:errored_items=>[{:failures=>[{:url=>"type"}, {:created_at=>"type"}], :data=>{"url"=>"blah", "created_at"=>"3/28/2018"}}]}
    end
  end
end
