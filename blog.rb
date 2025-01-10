%w[backports/latest tilt rack forwardable thread yaml json rubypants base64 digest/md5 time].each { |lib| require lib }

module ::Blog
  extend self, Forwardable
  attr_accessor :articles, :mutex, :map, :last_modified, :etag, :serialized, :secret, :pages

  class << self
    attr_accessor :url, :author, :email, :feedburner
  end

  def_delegators :map, :[], :[]=
  self.mutex = Mutex.new

  class Page
    extend Forwardable
    Instances = []
    attr_accessor :source, :url, :title, :status, :header, :file, :date, :header, :title, :slug, :use_layout
    def_delegators :Blog, :articles, :serialized

    def initialize(file, url = nil, status = 200, use_layout = true, options = {})
      @file, @status, @use_layout, @date, self.url = file, status, use_layout, Time.now, url
      @source = File.exist?(file) ? Tilt.new(file, options, &method(:load_file)).render(self) : file
      @source.replace RubyPants.new(@source).to_html if use_layout
      @header = {"Vary"=>"HTTP_X_REQUESTED_WITH", "X-UA-Compatible"=>"chrome=1", "Content-Language"=>"en-us",
                    "Content-Type"=>"text/html; charset=utf-8"}
      Instances << self
    end

    def url=(value)
      Blog.map&.delete_if { |k,v| v == self }
      Blog[value] = self if value
      @url = value
    end

    def layout;           @layout  ||= Tilt.new('templates/layout.haml').render(self) { content } end
    def content;          @content ||= Tilt.new('templates/page.haml').render(self) { @source }   end
    def response(content) [status, header.merge('Content-Length' => content.bytesize.to_s), [content]] end
    def load_meta(src)    YAML.load(src, permitted_classes: [Date]).each { |k,v| send("#{k}=", v) if respond_to? "#{k}=" }   end
    def index;            articles.index(self)                                                    end
    def next_page;        (index && index < articles.size - 1)  ? articles[index+1] : self        end
    def prev_page;        (index && index > 0)                  ? articles[index-1] : self        end
    def call(request)     response(compile)                                                       end
    def compile;          use_layout ? layout : source                                            end

    def date=(value)
      value = Time.parse value.to_s unless value.nil? or Time === value
      @date = value
    end

    def load_file(tilt = nil)
      data = File.read(file)
      return data unless use_layout and m = %r{^(([^\n]*(\w+:)[^\n]+\n)+)(\s*\n)+}m.match(data)
      load_meta m[1]
      data[m[0].size..-1]
    end
  end

  class Article < Page
    def initialize(file)
      super(file)
      self.slug ||= %r{([^\d\W][^\./]+)(\.\w{1,4})+$}.match(file)[1]
      self.url = "/%d/%02d/%s.html" % [date.year, date.month, slug]
    end
  end

  class ClientCache
    def initialize(app) @app = app end
    def call(env)
      request = env['blog.request'] = Rack::Request.new(env)
      Blog.load_articles(env) if request.params['token'] == Blog.secret
      return [304, {}, []] if env['HTTP_IF_NONE_MATCH'] == Blog.etag or env['HTTP_IF_MODIFIED_SINCE'] == Blog.last_modified
      @app.call(env).tap { |s,h,b| h.merge!('Etag' => Blog.etag, 'Last-Modified' => Blog.last_modified) }
    end
  end

  def load_articles(env = {})
    return mutex.synchronize { load_articles } if env["rack.multithread"]
    system 'git pull' unless env.empty?
    @secret = "update"
    not_found = Page.new("templates/not_found.haml", nil, 404)
    Page::Instances.delete(not_found)
    @map = Hash.new { not_found }
    @articles = Dir.glob("articles/*").sort.map { |f| Article.new(f) }
    load './pages.rb'
    @etag ||= Time.now.httpdate
  end

  def call(env)
    if env['PATH_INFO'] != "/cv.html"
      text = 'Redirect'
      [303, { 'Location' => "#{Blog.url}/cv.html",
        'Content-Type' => "text/html",
        'Content-Length' => text.size.to_s }, [text]]
#     if env['PATH_INFO'] == '/'
#       text = 'Redirect to last article'
#       [303, { 'Location' => "#{Blog.url}#{Blog.articles.last.url}",
#         'Content-Type' => "text/html",
#         'Content-Length' => text.size.to_s }, [text]]
    else
      self[env['PATH_INFO']].call env['blog.request']
    end
  end

  def new(app)
    self
  end
end

Blog.url        = "https://www.timfelgentreff.de"
Blog.author     = "Tim Felgentreff"
Blog.email      = "timfelgentreff@gmail.com"
Blog.feedburner = "blogbithugorg"

Blog.load_articles
