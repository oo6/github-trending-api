require File.expand_path '../app.rb', __FILE__
require 'minitest/autorun'
require 'rack/test'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe "GET '/'" do
  it "should successfully return a greeting" do
    get '/'
    assert_equal 'hello world', last_response.body
  end
end
