class ScrollingPhotoSet

  # This abstract class provides the methods for "animating" a set of photos in the
  # scrolling screensaver.  It relies on concrete subclasses to fetch the actual
  # photo metadata (URI, height, width, title, caption) from some remote service.
  # The goal is to provide a data structure that spoon-feeds the Roku SceneGraph XML
  # the necessary information to both fetch and 'animate' a set of photos.

  attr_accessor :error_message, :photos

  def initialize
    @error_message = nil
    @photos = []
  end

  def get(uri)
    begin
      response = HTTParty.get(uri, :verify => false)
      if response.success?
        response.body
      else
        @error_message = "#{response.code} - #{response.message}"
        nil
      end
    rescue HTTParty::Error => e
      @error_message = e.message
      nil
    end
  end
  
  def populate(n)
    @photos = fetch(n) # returns array of n instances of ScrollingPhoto
    @photos.each do |photo|
      photo.scale!
      photo.set_animation!
    end
    @photos
  end

end
