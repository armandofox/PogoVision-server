class GooglePhotoSet < ScrollingPhotoSet
  
  BASE_URI = 'https://picasaweb.google.com/data/feed/api/user'
  require 'active_support/core_ext/hash'

  def fetch(n=100)
    # get at least n random photos
  end

  protected

  def get_album_uris
    return [] unless (body = get "#{BASE_URI}/armandofox?kind=album&prettyprint=true")
    # the <entry> elements have an <id> child which is the full URL to get the photo
    # metadata from that album
    h = Hash.from_xml(body)
    h['feed']['entry'].map do |entry|
      entry['id'].strip
    end
  end

  def get_photos_from_album(album_uri)
    # <entry>
    #   <content type="mime/type" src="https://direct/link/to/pic.jpg"/>
    #   <gphoto:width>2400</gphoto:width>
    #   <gphoto:height>1600</gphoto:height>
    #   <media:group>
    #     <media:title>Photo Title</media:title>
    #   </media:group>
    # </entry>
    return [] unless (body = get "#{BASE_URI}/#{album_uri}?prettyprint=true")
    h = Hash.from_xml(body)
    h['feed']['entry'].map do |entry|
      if (entry['content']['type'] rescue nil) =~ /jpe?g$/i
        Photo.new(:uri => entry['content']['src'].strip,
          :height => entry['height'].to_i, :width => entry['width'].to_i)
      else
        nil
      end
    end.compact
  end

end
