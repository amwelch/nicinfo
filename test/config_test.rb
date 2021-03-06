# Copyright (C) 2011,2012,2013,2014 American Registry for Internet Numbers
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
# IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.


require 'tmpdir'
require 'fileutils'
require 'minitest/autorun'
require 'nicinfo/config'
require 'nicinfo/nicinfo_logger'
require 'nicinfo/constants'

class ConfigTest < Minitest::Test

  @work_dir = nil

  def setup

    @work_dir = Dir.mktmpdir

  end

  def teardown

    FileUtils.rm_r( @work_dir )

  end

  def test_init_no_config_file

    dir = File.join( @work_dir, "test_init_no_config_file" )

    c = NicInfo::Config.new( dir )
    assert_equal( "SOME", c.config[ "output" ][ "messages" ] )
    assert_equal( "NORMAL", c.config[ "output" ][ "data" ] )
    assert_nil( c.config[ NicInfo::OUTPUT ][ NicInfo::MESSAGES_FILE ] )
    assert_nil( c.config[ NicInfo::OUTPUT ][ NicInfo::DATA_FILE ] )
    assert_equal( "https://rdap.arin.net/registry", c.config[ NicInfo::BOOTSTRAP ][ NicInfo::IP_ROOT_URL ] )

    assert_equal( "NORMAL", c.logger.data_amount )
    assert_equal( "SOME", c.logger.message_level )

  end

  def test_init_config_file

    dir = File.join( @work_dir, "test_init_config_file" )
    Dir.mkdir( dir )
    not_default_config = <<NOT_DEFAULT_CONFIG
output:
  messages: NONE
  #messages_file: /tmp/NicInfo.messages
  data: TERSE
  #data_file: /tmp/NicInfo.data
bootstrap:
  ip_root_url: https://rdap.arin.net/bootstrap
NOT_DEFAULT_CONFIG
    f = File.open( File.join( dir, "config.yaml" ), "w" )
    f.puts( not_default_config )
    f.close

    c = NicInfo::Config.new( dir )
    assert_equal( "NONE", c.config[ NicInfo::OUTPUT ][ NicInfo::MESSAGES ] )
    assert_equal( "TERSE", c.config[ NicInfo::OUTPUT ][ NicInfo::DATA ] )
    assert_equal( true, c.config[ NicInfo::SECURITY ][ NicInfo::TRY_INSECURE ] )
    assert_nil( c.config[ NicInfo::OUTPUT ][ NicInfo::MESSAGES_FILE ] )
    assert_nil( c.config[ NicInfo::OUTPUT ][ NicInfo::DATA_FILE ] )
    assert_equal( "https://rdap.arin.net/bootstrap", c.config[ NicInfo::BOOTSTRAP ][ NicInfo::IP_ROOT_URL ] )

    assert_equal( "TERSE", c.logger.data_amount )
    assert_equal( "NONE", c.logger.message_level )

  end

  def test_setup_workspace

    dir = File.join( @work_dir, "test_setup_workspace" )

    c = NicInfo::Config.new( dir )
    c.logger.message_level = "NONE"
    c.setup_workspace

    assert( File.exist?( File.join( dir, "config.yaml" ) ) )
    assert( File.exist?( File.join( dir, "rdap_cache" ) ) )
    assert_equal( File.join( dir, "rdap_cache" ), c.rdap_cache_dir )

  end

end
