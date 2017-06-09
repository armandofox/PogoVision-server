require 'rubygems'
require 'bundler'
Bundler.require

require 'sinatra/base'
# require 'byebug'
require 'uri'
require 'figaro'
require 'json'

require_relative 'photo'
require_relative 'scrolling_photo_set'
require_relative 'google_photo_set'
require_relative 'test_photo_set'

class ScrollingPixServer < Sinatra::Application
  get '/' do
    # how many photo records to return?
    num_photos = (params[:n] || '100').to_i
    #provider = ((params[:p] || 'test') + "_photo_set").classify.constantize
    provider = ((params[:p] || 'google') + "_photo_set").classify.constantize
    response = provider.send(:new).populate(num_photos)
    content_type :json
    response.to_json
  end
end

require_relative 'figaro_support'
