require 'fileutils'


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
  Rake::Task["cv:pdf"].invoke
end

desc 'Remove static folder'
task :clobber do
  FileUtils.rm_rf 'static'
end

namespace :cv do
  static = File.expand_path("../static", __FILE__)
  date = `date +'%B %d, %Y'`

  task :style do
    Dir.chdir "cv" do
      system("compass compile \
                --require susy \
                --sass-dir stylesheets \
                --javascripts-dir javascripts \
                --image-dir public \
                --css-dir #{static} \
                stylesheets/style.scss") || raise Error
    end
  end

  desc "Make HTML CV"
  task :html => [:style] do
    Dir.chdir "cv" do
      system("pandoc --standalone \
                --section-divs \
                --smart \
                --template templates/cv.html \
                --from markdown+yaml_metadata_block+header_attributes+definition_lists \
                --to html5 \
                --variable=date:'#{date}' \
                --css style.css \
                --bibliography cv.bib \
                --output #{static}/cv.html cv.md") || raise Error
    end
  end

  desc "Make PDF CV"
  task :pdf => [:html, :pdftags] do
    system("wkhtmltopdf \
                --print-media-type \
                --orientation Portrait \
                --page-size A4 \
                --margin-top 15 \
                --margin-left 15 \
                --margin-right 15 \
                --margin-bottom 15 \
                #{static}/cv.html #{static}/cv.pdf") &&
      system("exiftool #{File.read(static + '/pdftags.txt')} #{static}/cv.pdf") || raise Error
  end

  task :pdftags do
    Dir.chdir("cv") do
      system("pandoc \
                --from markdown+yaml_metadata_block \
                --template templates/pdf.metadata \
                --template templates/pdf.metadata \
                --variable=date:'#{date}' \
                --output #{static}/pdftags.txt cv.md") || raise Error
    end
  end
end
