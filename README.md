# DEPRECATED

This gem has known security issues that I don't have time to fix or maintain, leaving it only for future reference.

# GeoLoc

A quick-and-dirty wrapper for the GeoIP gem that handles downloading and unzipping geodata.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'geo_loc'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install geo_loc

## Usage

Caveats:

- this gem is the minimum viable product for my purposes, your mileage may vary, feel free to fork and contribute if you run into issues
- it's designed for city level lookup resolution using Maxminds free city IP data, other lookup methods are not currently supported
- it assumes data files are .gzipped

The [GeoIP gem](https://github.com/cjheath/geoip) does a great job of accepting an IP address and digging through a MaxMind geolocation file to find a corresponding address.

One thing it doesn't do, however, is pull and unzip the data file for you.  This gem attempts to add this functionality, by automatically downloading the file if necessary and storing it in a sensible directory (or directory of your choice).

### Typical usage

    require 'geo_loc'

    if gdata = GeoLoc.new.ip('10.0.0.1')
      self.country = gdata[:country_code2]
      self.state = gdata[:region_name]
      self.city = gdata[:city_name]
      self.zip = gdata[:postal_code]
      self.lat = gdata[:latitude]
      self.long = gdata[:longitude]
    else
      # ...sadness
    end

This will download the latest release of Maxmind city data (see GeoIP gem for locations) if it doesn't already exist, and gzip it.

The #ip method rescues StandardError, so connectivity issues, file format issues will be logged and nil returned.

The hash returned by #ip comes directly from geoip, see geoip for details.

### Frequency of update

City data is **not** automatically refreshed.  If you're deploying your application once a week or more frequently, and the data file is stored in a location that is overwritten after every deploy, this isn't an issue since the next time GeoLoc.new.ip executes it will pull the file.  If it is an issue, you can manually force the sync data via:

	GeoLoc.new.sync_data!

Since syncing will pull down and decompress an 11mb+ file, users may experience a delay the first time GeoLoc.new.ip executes.  It's probably a good idea to do this as part of your deploy process.

Note that #sync_data! does not rescue exceptions.

### Overriding default locations

Without any initialization options, GeoLoc will try to pick default directory locations for you.  If Rails is defined, it will use Rails.root + '/tmp'.  If Rails isn't defined, it will use '/tmp'.  An example of customized options:

	GeoLoc.new(filename: 'my-file', 
		geodata_dir: 'my-dir', 
		geodata_file: 'geodata', 
		compressed_geodata_file: 'geodata.gz', 
		geodata_url: 'http://thedata.gz', 
		logger: MyLogger.new('/tmp/mylogger.log'))

In general, the options will work if only one is passed, for example if you want to customize the data where geodata is stored.

### Unit tests

If youre testing code that depends on this gem, the 11mb file will be downloaded the first time the spec runs.  I recommend letting this happen (not being a mockist), it should only happen once, and it will help you to ensure that it actually works.

Warnings like:

	warning: instance variable @data_exists not initialized

...are being triggered on running the gem's specs, if you know the cause and resolution to this issue, please let me know.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/geo_loc/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
