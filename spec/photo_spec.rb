require File.expand_path '../spec_helper.rb', __FILE__

describe Photo do
  describe 'scaling' do
    specify 'narrow photo becomes wide enough' do
      expect(Photo.new(:width => 10, :height => 20).scale!.width).to be > Photo::MIN_PHOTO_WIDTH
    end
    specify 'too-wide photo becomes narrow enough' do
      old_w,old_h = 4000,2000
      scaled = Photo.new(:width => old_w, :height => old_h).scale!
      expect(scaled.width).to be < Photo::SCREEN_WIDTH
      expect(scaled.height/old_h.to_f).to be_within(0.1).of(scaled.width/old_w.to_f)
    end
  end
end
