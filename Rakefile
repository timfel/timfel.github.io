require 'fileutils'
require 'tilt'
require 'bibtex'


desc 'Generate static pages'
task :default do
  load './blog.rb'
  FileUtils.mkdir_p 'static'
  FileUtils.cp_r 'public', 'static/'
  FileUtils.cp_r 'lib', 'static/'
  FileUtils.cp 'CNAME', 'static/'
  Blog::Page::Instances.each do |page|
    FileUtils.mkdir_p File.join(".", "static", File.dirname(page.url))
    filename = File.join('static', page.url)
    File.open(filename, 'w') do |f|
      f << page.compile
    end
  end
  File.open(File.join('static', 'blog.html'), 'w') do |f|
    f << "<meta HTTP-EQUIV='REFRESH' content='0; url=&quot;#{Blog::Page::Instances.select{ |p| p.kind_of? Blog::Article }.last.url}&quot;'>"
  end
  Rake::Task["cv:pdf"].invoke
end

desc 'Remove static folder'
task :clobber do
  FileUtils.rm_rf 'static'
end

namespace :cv do
  static = File.expand_path("../static", __FILE__)
  date = `date +'%B %d, %Y'`

  desc "Make HTML CV"
  task :bib => [] do
    cv = File.expand_path("../cv/cv.md", __FILE__)
    File.open(cv, "w") do |f|
      f << Tilt.new("#{cv}.erb").render(nil, bibtex: BibTeX.open(cv.sub(".md", ".bib")))
    end
  end

  task :html => [:bib] do
    Dir.chdir "cv" do
      system("pandoc --standalone \
                --section-divs \
                --citeproc \
                --template templates/cv.html \
                --from markdown+yaml_metadata_block+header_attributes+definition_lists \
                --metadata pagetitle=\"CV\" \
                --to html5 \
                --variable=date:'#{date}' \
                --css public/style.css \
                --bibliography cv.bib \
                --csl bib.csl \
                --output #{static}/cv.html cv.md") || raise
    end
  end

  desc "Make PDF CV"
  task :pdf => [:html, :pdftags] do
    system("wkhtmltopdf \
                --print-media-type \
                --orientation Portrait \
                --enable-local-file-access \
                --page-size A4 \
                --margin-top 15 \
                --margin-left 15 \
                --margin-right 15 \
                --margin-bottom 15 \
                #{static}/cv.html #{static}/cv.pdf") &&
      system("exiftool #{File.read(static + '/pdftags.txt')} #{static}/cv.pdf") || raise
  end

  task :pdftags do
    Dir.chdir("cv") do
      system("pandoc \
                --from markdown+yaml_metadata_block \
                --template templates/pdf.metadata \
                --template templates/pdf.metadata \
                --variable=date:'#{date}' \
                --output #{static}/pdftags.txt cv.md") || raise
    end
  end
end
