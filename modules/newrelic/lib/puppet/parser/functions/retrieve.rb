require 'open-uri'

# return concatenated content of all URLs specified as arguments
Puppet::Parser::Functions::newfunction(:retrieve, :type => :rvalue) do |args|
  content = ''

  args.each() do |url|
    open(url) do |stream|
      content << stream.read()
    end
  end

  content
end
