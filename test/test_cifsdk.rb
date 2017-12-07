require 'minitest/autorun'
require 'cifsdk'

# http://www.ruby-doc.org/stdlib-1.9.3/libdoc/minitest/unit/rdoc/MiniTest.html

@remote = 'https://localhost'
@token = '1234444'

class TestCifSdk < Minitest::Test
  def setup
    @cli = CIFSDK::Client.new(:remote => @remote, :token => @token)
  end
  
  def test_token
    assert_equal @token, @cli.token
  end
  
  def test_remote
    assert_equal @remote, @cli.remote
  end
end
