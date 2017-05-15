require 'rubygems'
require 'bundler'
Bundler.require

require 'sinatra/base'
require 'byebug'
require 'uri'
require 'figaro'

require_relative 'photo'
require_relative 'scrolling_photo_set'
require_relative 'google_photos'


class ScrollingPixServer < Sinatra::Application
  get '/' do
    puts Figaro.env.example!
    # how many photo records to return?
    num_photos = (params[:n] || '100').to_i
    content_type :json
    ScrollingPhotoSet.new(GooglePhotos).populate(n).to_json
  end
end

require_relative 'figaro_support'
