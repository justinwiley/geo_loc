require 'geo_loc/version'
require 'geoip'
require 'open-uri'
require 'zlib'
require 'logger'

# Geolocates given IP using maxminds geo ip database
# Pulls database down if it doesnt exists
# Note that in test environment (outside of mocked unit tests), will pull the ~11mb file, leading to lengthened initial test run

class GeoLoc
  # FILENAME = 'GeoLiteCity.dat'
  # GEODATA_FILE = File.join(Rails.root, '/tmp/', FILENAME)
  # COMPRESSED_GEODATA_FILE = File.join(Rails.root, FILENAME + '.gz')
  # GEODATA_URL = 'http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz'

  attr_accessor :filename, :geodata_file, :geodata_dir, :compressed_geodata_file, :geodata_url, :logger

  def initialize(filename: nil, geodata_dir: nil, geodata_file: nil, compressed_geodata_file: nil, geodata_url: nil, logger: nil)
    self.filename = filename || 'GeoLiteCity.dat'
    self.geodata_dir = geodata_dir || root_dir
    self.geodata_file = geodata_file || File.join(self.geodata_dir, self.filename)
    self.compressed_geodata_file = compressed_geodata_file || self.geodata_file + '.gz'
    self.geodata_url = geodata_url || 'http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz'
    self.logger = logger || logger_method
  end

  def logger_method; defined?(Rails) && Rails.respond_to?(:logger) ? Rails.logger : Logger.new('/tmp/geoloc.log'); end
  def root_dir; defined?(Rails) && Rails.respond_to?(:root) ? File.join(Rails.root, '/tmp') : '/tmp'; end

  def download_compressed_geodata
    logger.info "Downloading geodata #{geodata_url}"
    open(compressed_geodata_file, 'wb') {|f| f << open(geodata_url).read }
  end

  def decompress_geodata
    logger.info "Decompressing #{compressed_geodata_file}"
    File.open(compressed_geodata_file) do |cf|
      begin
        gz = Zlib::GzipReader.new(cf)
        File.open(geodata_file, 'w'){|f| f << gz.read}
      ensure
        gz.close
      end
    end
  end

  def sync_data
    download_compressed_geodata
    decompress_geodata
  end

  def ip ip_address
    begin
      if @data_exists || File.exist?(geodata_file)
        @data_exists = true
      else
        sync_data
      end

      @geoip ||= GeoIP.new(geodata_file)
      @geoip.city(ip_address).try(:to_hash)
    rescue => e
      logger.error "Failed to geo ip address #{ip_address}\n#{e}\n#{e.backtrace.join("\n")}"
      nil
    end
  end
end