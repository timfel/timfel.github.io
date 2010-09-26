xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  xml.title '#{Blog.url.gsub("http://", "")}'
  xml.id '#{Blog.url}'
  xml.updated Blog.last_modified
  xml.author { xml.name Blog.author }

  articles.each do |article|
    xml.entry do
      xml.title article.title
      xml.link "rel" => "alternate", "href" => "#{Blog.url}/#{article.url}"
      xml.id article.url
      xml.published article.date.iso8601
      xml.updated article.date.iso8601
      xml.author { xml.name Blog.author }
      xml.content article.source.gsub(%r{/20\d\d/\d\d/}, "#{Blog.url}\\0"), "type" => "html"
    end
  end
end
