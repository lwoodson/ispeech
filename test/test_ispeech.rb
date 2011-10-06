require 'helper'
require 'ispeech'
require 'mocha'
require 'uri'

class TestIspeech < Test::Unit::TestCase
  context "the parameterize method" do
    should "convert hash into http param string" do
      assert_equal "a=1&b=2", ISpeech.parameterize(:a=>'1', :b=>'2')
    end

    should "convert hash with numeric values into http param string" do
      assert_equal "a=1&b=2", ISpeech.parameterize(:a=>1,:b=>2)
    end

    should "substitute + for spaces in values" do
      assert_equal "a=This+is+a+test", ISpeech.parameterize(:a=>'This is a test')
    end
  end

  context "the decode_param_string" do
    should "decode params into open struct" do
      assert_equal OpenStruct.new({:a=>"1",:b=>"2"}), ISpeech.decode_param_string("a=1&b=2")
    end
  end

  context "the Client.information method" do
    should "make information request and decode param string" do
      Net::HTTP.expects(:get).with(URI.parse("http://api.ispeech.org/api/rest?apikey=key&action=information")).returns 'a=1&b=2'
      client = ISpeech::Client.new :api_key => 'key'
      result = client.information
      assert_equal '1', result.a
      assert_equal '2', result.b
    end
  end

  context "the Client.convert method" do
    should "make convert request and return binary results" do
      Net::HTTP.expects(:get).with(URI.parse("http://api.ispeech.org/api/rest?apikey=key&action=convert&text=This+is+a+test")).returns 'result'
      client = ISpeech::Client.new :api_key => 'key'
      assert_equal 'result', client.convert(:text => 'This is a test')
    end

    should "make convert request with :filename opt and write result to file" do
      Net::HTTP.expects(:get).with(URI.parse("http://api.ispeech.org/api/rest?apikey=key&action=convert&text=This+is+a+test&filename=test.mp3")).returns 'result'
      client = ISpeech::Client.new :api_key => 'key'
      client.convert(:text => 'This is a test', :filename => 'test.mp3')
      assert File.exists? 'test.mp3'
      File.open 'test.mp3' do |f|
        result = f.read
        assert_equal 'result', result
      end
      File.delete 'test.mp3'
    end
  end
end
