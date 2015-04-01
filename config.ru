load './blog.rb'
use Blog::ClientCache
use Rack::Deflater
use Rack::Static, :urls => ["/images", "/videos", "/uni"], :root => "public"
use Rack::Static, :urls => ["/lib"], :root => "."
use Rack::Static, :urls => ["/blog.js"], :root => "templates"
run Blog
