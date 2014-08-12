# require 'pry'
require_relative '../../lib/geo_loc.rb'
require_relative '../spec_helper'

describe GeoLoc do
  let(:gl) { GeoLoc.new }
  let(:gddir) { gl.geodata_dir }
  let(:gdfile) { gl.geodata_file }
  let(:gdzfile) { gl.compressed_geodata_file }
  let(:gdurl) { gl.geodata_url }
  let(:double_io) { double('IO', read: 'data')}

  before do
    GeoLoc.send(:remove_const, :Rails) if defined? GeoLoc::Rails
  end

  describe 'intialize' do
    it 'provides default locations for storing geodata, url of where to download data from' do
      gdfile.should be == "/tmp/GeoLiteCity.dat"
      gddir.should be == '/tmp'
      gdzfile.should be == "/tmp/GeoLiteCity.dat.gz"
      gdurl.should be ==  "http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz"
    end

    it 'allows these values to be overridden as options' do
      gl = GeoLoc.new geodata_dir: '/mydir'
      gl.geodata_dir.should be == '/mydir'
    end

    it 'uses Rails envrionment root dir if Rails is defined' do
      class GeoLoc::Rails
        def self.root; 'rails-root'; end
        def self.logger; Logger.new('/dev/null'); end
      end
      gddir.should be == 'rails-root/tmp'
    end
  end

  describe 'refreshing geo ip data' do
    before do
      [gdzfile, gdfile].map{|f| FileUtils.rm(f) if File.exist?(f) }
    end

    it '#download_compressed_geodata pulls down compressed geoip data' do
      gl.should_receive(:open).with(gdurl).and_return(double_io)
      gl.should_receive(:open).with(gdzfile, 'wb').and_yield([])

      gl.download_compressed_geodata
    end

    it '#decompress_geodata decompresses geodata using zlib' do
      contents = 'test data'
      Zlib::GzipWriter.open(gdzfile) do |gz|
        gz.write contents
      end

      File.exist?(gdfile).should be_falsey
      gl.decompress_geodata
      res = File.read(gdfile)
      res.should be == contents
    end

    it '#sync_data does both, downloads and decompresses' do
      gl.should_receive(:download_compressed_geodata)
      gl.should_receive(:decompress_geodata)
      gl.sync_data
    end
  end

  describe '#ip' do
    let(:double_geoip) { double(GeoIP, city: 'city data') }
    let(:ip) { '127.0.0.1' }

    it 'returns the geo data for a given ip address' do
      gl.stub(:sync_data)
      double_geoip.should_receive(:city).with(ip)
      GeoIP.should_receive(:new).with(gdfile).and_return(double_geoip)
      gl.ip(ip)
    end
  
    it 'should sync the data file if it doesnt exist' do
      File.should_receive(:exist?).and_return(false)
      gl.should_receive(:sync_data)
      GeoIP.should_receive(:new).with(gdfile).and_return(double_geoip)
      gl.ip(ip)
    end

    it 'should not sync if it does' do
      File.should_receive(:exist?).and_return(true)
      gl.should_not_receive(:sync_data)
      GeoIP.should_receive(:new).with(gdfile).and_return(double_geoip)
      gl.ip(ip)
    end

    it 'rescues exceptions, returning nil' do
      File.should_receive(:exist?).and_raise(StandardError)
      gl.ip(ip).should be_nil
    end
  end
end