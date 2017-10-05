Pod::Spec.new do |s|
  s.name = "TagsView"
  s.version = "2.1.3"
  s.summary = "Quickly create a view with tags, written in Swift"
  s.homepage = "https://github.com/tomoponzoo/TagsView"
  s.license = "MIT"
  s.social_media_url = "http://twitter.com/tomoponzoo"
  s.authors = { "tomoponzoo" => "tomoponzoo@gmail.com" }
  s.source = { :git => "https://github.com/tomoponzoo/TagsView.git", :tag => s.version }

  s.ios.deployment_target = "9.0"

  s.source_files  = "Classes/*.swift"
end
