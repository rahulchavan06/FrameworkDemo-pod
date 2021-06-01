Pod::Spec.new do |spec|

  spec.name         = "CommunicationLibrary"
  spec.version      = "1.0.2"
  spec.summary      = "This will provides the CommunicationLibrary.xcframework as a pod installer"

  spec.description  = <<-DESC
	testing xcframework through pod, testing xcframework through pod, testing xcframework through pod, testing xcframework through pod, testing xcframework through pod, testing xcframework through pod
                   DESC

  spec.homepage     = "https://github.com/rahulchavan06/FrameworkDemo-pod"
  spec.author       = { "Rahul Chavan" => "rahul.chavan06@mail.com" }
  spec.license      = "MIT License"
  spec.platform     = :ios, "11.0"
  spec.source       = { :git => "https://github.com/rahulchavan06/FrameworkDemo-pod.git", :tag => "#{spec.version}" }
  spec.vendored_frameworks = 'CommunicationLibrary.xcframework'
  spec.swift_version = "5.0"
  spec.dependency 'Realm', '~> 1.0'

end

