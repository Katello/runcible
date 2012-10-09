# Copyright (c) 2012 Eric D Helms
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'rubygems'
require 'minitest/autorun'
require 'minitest/mock'
require './lib/runcible/base'


class TestBase < MiniTest::Unit::TestCase
  def setup
    Runcible::Base.config = {
      :base_url => "http://localhost/",
      :user     => "test_user",
      :password => "test_password",
      :oauth    => "test_oauth",
      :headers  => { :content_type => 'application/json',
                     :accept       => 'application/json' }
    }

    @base = Runcible::Base.new
  end

  def test_config
    assert !Runcible::Base.config.nil?
  end

  def test_process_response_returns_hash
    json = { :a => "test", :b => "data" }.to_json
    data = @base.process_response(json)

    assert data["a"] = "test"
  end

  def test_process_response_returns_string
    string = "true"
    data = @base.process_response(string)

    assert data = "true"
  end
end
