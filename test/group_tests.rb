require 'test_helper'

describe AeEasy::Qa::Validate do
  describe "group tests" do
    it 'should test group test' do
      test_val = Proc.new do |qa, data|
        qa.errors[:rank_val] = 'fail' if data.find{|hash| hash['rank'] > 5 }
      end
      data = [{'rank' => 1}, {'rank' => 3}, {'rank' => 2}, {'rank' => 6}]
      qa = AeEasy::Qa::Validate.new(data)
      test_val.call(qa, data)
      results = qa.run
      assert_equal results, {:errored_items=>[], :rank_val=>"fail"}
    end
  end
end
