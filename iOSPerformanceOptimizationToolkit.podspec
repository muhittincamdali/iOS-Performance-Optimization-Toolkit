Pod::Spec.new do |s|
  s.name             = 'iOSPerformanceOptimizationToolkit'
  s.version          = '1.0.0'
  s.summary          = 'Performance optimization toolkit for iOS applications.'
  s.description      = <<-DESC
    iOSPerformanceOptimizationToolkit provides tools for optimizing iOS app performance.
    Features include memory profiling, CPU monitoring, battery optimization, network
    performance analysis, and automated performance testing.
  DESC

  s.homepage         = 'https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Muhittin Camdali' => 'contact@muhittincamdali.com' }
  s.source           = { :git => 'https://github.com/muhittincamdali/iOS-Performance-Optimization-Toolkit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.osx.deployment_target = '12.0'

  s.swift_versions = ['5.9', '5.10', '6.0']
  s.source_files = 'Sources/**/*.swift'
  s.frameworks = 'Foundation', 'QuartzCore', 'os'
end
