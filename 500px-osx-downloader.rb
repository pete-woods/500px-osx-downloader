#!/usr/bin/env ruby

require 'json'
require 'net/http'
require 'tempfile'
require 'uri'

class Downloader
  def initialize(category: category, consumer_key: 'elrnOy6kZYUxZMMOBttIVDAdOSq6AoDP2J4VnBry')
    @category = category
    @consumer_key = consumer_key

    uri = URI::HTTPS.build({
      :host => 'api.500px.com',
      :path => '/v1/photos',
      :query => URI.encode_www_form(
        'consumer_key' => @consumer_key,
        'feature' => 'popular',
        'only' => @category,
        'image_size' => '2048',
      ),
    })

    response = Net::HTTP.get(uri)
    @json = JSON.parse(response)
  end

  def random()
    photo = @json['photos'].sample
    set_wallpaper(photo)
  end

  private

  def set_wallpaper(photo)
    photo_url = photo['image_url']

    image = Net::HTTP.get(URI(photo_url))
    image_file = Tempfile.new('500px.jpg')
    image_file.write(image)
    image_file.close
  
    %x(osascript -e 'tell application "System Events"
      set desktopCount to count of desktops
      repeat with desktopNumber from 1 to desktopCount
        tell desktop desktopNumber
          set picture to "#{image_file.path}"
        end tell
      end repeat
    end tell')
  end
end

if __FILE__ == $0
  downloader = Downloader.new(:category => 'Landscapes')
  downloader.random
end
