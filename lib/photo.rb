class Photo

  # Assuming 1080p TV
  SCREEN_WIDTH = 1280
  SCREEN_HEIGHT = 720

  # Desired min/max width and height of displayed photos
  MIN_PHOTO_WIDTH = 100
  MAX_PHOTO_WIDTH = 1000
  MIN_PHOTO_HEIGHT = 100
  MAX_PHOTO_HEIGHT = 800

  # Range of animation durations (seconds)
  FASTEST_ANIMATION = 4
  SLOWEST_ANIMATION = 15

  attr_accessor :uri, :height, :width, :duration
  attr_accessor :animation_vector_key, :animation_vector_key_value, :translation

  def initialize(args={})
    @uri,@height,@width = args.values_at(:uri,:height,:width)
    @animation_vector_key = [0.0, 1.0]
    @animation_vector_key_value = nil
    @translation = nil
  end

  def to_json(*args, &block)
    {:uri => @uri, :height => @height, :width => @width,
      :duration => @duration, :translation => translation,
      :animation_vector_key => @animation_vector_key,
      :animation_vector_key_value => @animation_vector_key_value }.to_json(*args,&block)
  end

  def animated? ; !!@animation_vector_key_value ; end

  # Scale the photo to between `MIN_PHOTO_WIDTH` and `MAX_PHOTO_WIDTH`, but never taller
  # than `MAX_PHOTO_HEIGHT`
  def scale!
    widthf = width.to_f
    heightf = height.to_f
    # range of allowable scales is constrained by min/max desired width & height
    min_scale_factor = [MIN_PHOTO_WIDTH/widthf, MIN_PHOTO_HEIGHT/heightf].max
    max_scale_factor = [MAX_PHOTO_WIDTH/widthf, MAX_PHOTO_HEIGHT/heightf].min
    # choose a scale somewhere in that range
    scale_factor = min_scale_factor + rand() * (max_scale_factor - min_scale_factor)
    @height = (@height * scale_factor).round
    @width =  (@width * scale_factor).round
    self
  end

  # Determine photo placement across screen and how slow/fast it will animate.
  # Width and height must be finalized before calling this.
  # Eventually, this should be "smart" in that larger photos should be "heavier" and move
  # more slowly, but for now it's uniform random distribution.
  #
  # The Roku SceneGraph XML definition expects an `<Animation>` element to have a
  # `duration` attribute specifying the animation's duration in seconds, and a child
  # element `<Vector2DFieldInterpolator>` that controls the animation trajectory over
  # that duration.  The `Vector2DFieldInterpolator` has attributes `key` and `keyValue`.
  # `key` is a variable-length array of floats ranging between 0.0 to 1.0 and representing
  # percent-complete points for the animation; the `keyValue` array contains sets of
  # (x,y) coordinates corresponding to where the animation should be at each such point in
  # time using linear interpolation (other interpolators are available, but simplicity).
  # For a simple 1-segment trajectory of a photo rising from the bottom of the screen
  # to the top, `key` is always the array `[0.0, 1.0]` and `keyValue` is the nested array
  # `[[X,screenHeight], [X,-photo_height]]` where `photo_height` is the photo's height (so
  # it scrolls ALL THE WAY off the screen) and `X` is the chosen x-offset for the animation.
  #
  
  def set_animation!
    # range of X offset is 0 to (screen width - photo width)
    x_offset = (rand() * (SCREEN_WIDTH - width)).round
    @translation = [ x_offset, SCREEN_HEIGHT ]
    @animation_vector_key_value = [
      [ x_offset,SCREEN_HEIGHT ], [x_offset, -height]
    ]
    # duration
    @duration = (rand() * (SLOWEST_ANIMATION - FASTEST_ANIMATION)).round + FASTEST_ANIMATION
    self
  end
end
