$LOAD_PATH.unshift File.expand_path("..", __FILE__)
require "sinatra"
require "blog"

use Blog::ClientCache
use Rack::Static, :urls => ["/images", "/videos", "/uni"], :root => "public"
use Rack::Deflater
use Blog
