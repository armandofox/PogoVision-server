module Figaro
  def path
    @path ||= File.join(ScrollingPixServer.settings.root, "application.yml")
    puts @path
  end
  def environment
    ScrollingPixServer.settings.environment
  end
end
Figaro.env.each do |key, value|
  ENV[key] = value unless ENV.key?(key)
end
