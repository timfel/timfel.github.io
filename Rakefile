require 'fileutils'

desc 'Generate static pages'
task :default do
  load './blog.rb'
  FileUtils.mkdir_p 'static'
  FileUtils.cp_r 'public', 'static'
  Blog::Page::Instances.each do |page|
    FileUtils.mkdir_p File.join(".", "static", File.dirname(page.url))
    filename = File.join('static', page.url)
    File.open(filename, 'w') do |f|
      f << page.layout
    end
  end
end

desc 'Remove static folder'
task :clobber do
  FileUtils.rm_rf 'static'
end
