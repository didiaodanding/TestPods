Pod::Spec.new do |s|
  s.name                = "LFTestPods"
  s.version             = "0.0.3"
  s.summary             = "TestPods only for test."
  s.homepage            = "https://github.com/didiaodanding/TestPods.git"
  s.license             = "MIT"
  s.author              = { "haleli" => "1404012659@qq.com" }
  s.social_media_url    = "https://github.com/didiaodanding"
  s.platform            = :ios, "8.0"
  s.source              = { :git => "https://github.com/didiaodanding/TestPods.git", :tag => s.version }
  s.requires_arc        = true
  s.public_header_files = "NewLLDebugTool/**/*.h"
#  s.source_files      = "NewLLDebugTool/**/*.{h,m,swift,c}"
  s.source_files	    = "NewLLDebugTool/**/*.{h,m,mm}"
  s.resources		    = "NewLLDebugTool/**/*.{xib,storyboard,bundle,js}"
  s.vendored_frameworks = 'Frameworks/*.framework'
  #s.swift_version = "4.2"

  # s.xcconfig = {
  #     "GCC_PREPROCESSOR_DEFINITIONS" => "ISLOCAL=2"
  # }
#  s.dependency            "FMDB"
#  s.dependency       "SSZipArchive"
  #s.dependency      "BSBacktraceLogger"
  # s.dependency    "NewSwiftMonkeyPaws"
  s.framework      = 'IOKit'

  #s.subspec 'Network' do |ss|
  #  ss.source_files             = "NewLLDebugTool/Components/Network/**/*.{h,m}"
  #  ss.resources                = "NewLLDebugTool/Components/Network/**/*.{xib,storyboard,bundle}"
  #  ss.public_header_files      = "NewLLDebugTool/Components/Network/**/*.h"
  #  ss.dependency                 "NewLLDebugTool/StorageManager"
  #end

  #s.subspec 'Log' do |ss|
  #  ss.source_files             = "NewLLDebugTool/Components/Log/**/*.{h,m}"
  #  ss.resources                = "NewLLDebugTool/Components/Log/**/*.{xib,storyboard,bundle}"
  #  ss.public_header_files      = "NewLLDebugTool/Components/Log/**/*.h"
  #  ss.dependency                 "NewLLDebugTool/StorageManager"
  #end

  # s.subspec 'Crash' do |ss|
  #   ss.source_files             = "NewLLDebugTool/Components/Crash/**/*.{h,m,mm}", "NewLLDebugTool/OCMonkeyPaws/*.{h,m}" , "NewLLDebugTool/DebugTool/PublicHeader/*.{h,m}" 
  #   ss.resources                = "NewLLDebugTool/Components/Crash/**/*.{xib,storyboard,bundle}"
  #   ss.public_header_files      = "NewLLDebugTool/Components/Crash/**/*.h", "NewLLDebugTool/OCMonkeyPaws/*.h" ,"NewLLDebugTool/DebugTool/PublicHeader/*.h" 
  #   ss.dependency                 "NewLLDebugTool/StorageManager"
  #   ss.dependency                 "NewLLDebugTool/General"
  # end

#  s.subspec 'AppInfo' do |ss|
#    ss.source_files             = "NewLLDebugTool/Components/AppInfo/**/*.{h,m}"
##    ss.resources                = "LLDebugTool/Components/AppInfo/**/*.{xib,storyboard,bundle}"
#    ss.public_header_files      = "NewLLDebugTool/Components/AppInfo/**/*.h"
#    ss.dependency                 "NewLLDebugTool/General"
#  end

    
  # s.subspec 'SSZipArchive' do |ss|
  #   ss.source_files = 'NewLLDebugTool/SSZipArchive/*.{m,h}'
  #   ss.public_header_files = 'NewLLDebugTool/SSZipArchive/*.h'
  # end


 # s.subspec 'Sandbox' do |ss|
 #   ss.source_files             = "NewLLDebugTool/Components/Sandbox/**/*.{h,m}"
 #   ss.resources                = "NewLLDebugTool/Components/Sandbox/**/*.{xib,storyboard,bundle}"
 #   ss.public_header_files      = "NewLLDebugTool/Components/Sandbox/**/*.h"
 #   ss.dependency                 "NewLLDebugTool/General"
 #   # ss.dependency                 "NewLLDebugTool/SSZipArchive"
 #   ss.dependency                 "SSZipArchive"
 # end

 #s.subspec 'Screenshot' do |ss|
 #   ss.source_files             = "NewLLDebugTool/Components/Screenshot/**/*.{h,m}"
##    ss.resources                = "LLDebugTool/Components/Screenshot/**/*.{xib,storyboard,bundle}"
 #   ss.public_header_files      = "NewLLDebugTool/Components/Screenshot/**/*.h"
 #   ss.dependency                 "NewLLDebugTool/General"
 # end

 # s.subspec 'StorageManager' do |ss|
 #   ss.source_files             = "NewLLDebugTool/Components/StorageManager/**/*.{h,m}"
##    ss.resources               = "LLDebugTool/Components/StorageManager/**/*.{xib,storyboard,bundle}"
 #   ss.public_header_files      = "NewLLDebugTool/Components/StorageManager/**/*.h"
##    ss.dependency                 "FMDB"
 #   ss.dependency                 "NewLLDebugTool/General"
  #end

 # s.subspec 'General' do |ss|
 #   ss.source_files             = "NewLLDebugTool/Config/*.{h,m}" , "NewLLDebugTool/Components/General/**/*.{h,m}"
 #   ss.resources                = "NewLLDebugTool/Components/General/**/*.{xib,storyboard,bundle}"
 #   ss.public_header_files      = "NewLLDebugTool/Config/*.h" , "NewLLDebugTool/Components/General/**/*.h"
 # end



end
