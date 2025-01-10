# Additional pages defined in here
# Blog::Page.new(`coffee -p templates/blog.coffee`, "/blog.js", 200, false).header["Content-Type"] = "text/javascript"

Blog::Page.new(<<-JAVASCRIPT, "/articles.js", 200, false).header["Content-Type"] = "text/javascript"
var articles;
articles = #{JSON.pretty_generate Blog.articles.map(&:url)};
titles   = #{JSON.pretty_generate Blog.articles.inject({}) { |h,a| h.merge(a.url => a.title) }};
JAVASCRIPT

Blog::Page.new("templates/blog.coffee", "/blog.js", 200, false).header["Content-Type"] = "text/javascript"
Blog::Page.new("templates/feed.builder", "/feed.xml", 200, false).header["Content-Type"] = "text/xml"
Blog::Page.new("User-agent: *\nAllow: /\n", "/robots.txt", 200, false).header["Content-Type"] = "text/plain"

Blog::Page.new("templates/research.haml", "/research.html", 200)
Blog::Page.new("templates/presentations.haml", "/presentations.html", 200)

index = Blog::Page.new("templates/index.haml", "/index.html", 200, false)
