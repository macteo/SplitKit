Pod::Spec.new do |s|
  s.name                  = "SplitKit"
  s.version               = "1.0.1"
  s.summary               = "Resizable split view that accomodates two view controllers for iOS."
  s.description           = <<-DESC
  Drop-in single file swift component to add a resizable split view that can host two controllers.

  Heavily inspired by the Swift Playgrounds app for iPad, _SplitKit_ gives you the ability to easily present two `UIView`s side by side (or stacked one on top of the other) baked by different `UIViewControllers`. Everything is implemented in a single _.swift_ file to easily drop it in in existing projects. CocoaPods, Carthage and plain Dynamic Framework are supported as well for your convenience. The end user has the ability to resize the views just dragging the separator like each macOS counterpart, when the drag is performed a convenient handle appears to highlight the resizing operation. If the separator is really close to one of the edges, it will snap to it with an enjoyable animation and the handle won't disappear to highlight the hidden view position.
                            DESC
  s.homepage              = "https://github.com/macteo/SplitKit"
  s.license               = { :type => "MIT", :file => "LICENSE" }
  s.author                = { "Matteo Gavagnin" => "m@macteo.it" }
  s.social_media_url      = "https://twitter.com/macteo"

  s.ios.deployment_target = "9.0"

  s.source                = { :git => "https://github.com/macteo/SplitKit.git", :tag => "v#{s.version}" }
  s.source_files          = "SplitKit/**/*.{swift}"
  s.requires_arc          = true
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0', 'SWIFT_OPTIMIZATION_LEVEL' => '-Owholemodule' }
end
