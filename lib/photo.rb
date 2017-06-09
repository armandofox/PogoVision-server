class Photo

  # Assuming 1920 x 1080 resolution (1080p)
  SCREEN_WIDTH = 1920
  SCREEN_HEIGHT = 1080
  MIN_PHOTO_WIDTH = 320
  MAX_PHOTO_WIDTH = 1200

  # Range of animation durations (seconds)
  FASTEST_ANIMATION = 4
  SLOWEST_ANIMATION = 15

  attr_accessor :uri, :height, :width, :duration
  attr_accessor :animation_vector_key, :animation_vector_key_value, :translation

  def initialize(args={})
    @uri,@height,@width = args.values_at(:uri,:height,:width)
    @animation_vector_key = "[0.0, 1.0]"
    @animation_vector_key_value = nil
    @translation = nil
  end

  def to_json(*args, &block)
    {:uri => @uri, :height => @height, :width => @width,
      :duration => @duration, :translation => translation,
      :animation_vector_key => @animation_vector_Key,
      :animation_vector_key_value => @animation_vector_key_value }.to_json(*args,&block)
  end

  def animated? ; !!@animation_vector_key_value ; end

  # Scale the photo to between `MIN_PHOTO_WIDTH` and `MAX_PHOTO_WIDTH`, but never taller
  # than `MAX_PHOTO_HEIGHT`
  def scale!
    widthf = width.to_f
    min_scale_factor = MIN_PHOTO_WIDTH/widthf
    max_scale_factor = MAX_PHOTO_WIDTH/widthf
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
  # to the top, `key` is always the string `"[0.0, 1.0]"` and `keyValue`is
  # `"[[X,screenHeight], [X,-photo_height]]"` where `photo_height` is the photo's height (so
  # it scrolls ALL THE WAY off the screen) and `X` is the chosen x-offset for the animation.
  #
  
  def set_animation!
    # range of X offset is 0 to (screen width - photo width)
    x_offset = (rand() * (SCREEN_WIDTH - width)).round
    @animation_vector_key_value =
      sprintf "[[%d, %d], [%d, %d]]", x_offset, SCREEN_HEIGHT, x_offset, -height
    @translation = sprintf "[%d, %d]", x_offset, SCREEN_HEIGHT
    # duration
    @duration = (rand() * (SLOWEST_ANIMATION - FASTEST_ANIMATION)).round + FASTEST_ANIMATION
    self
  end
end
