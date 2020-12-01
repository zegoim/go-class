#运行环境 ruby
#依赖库 xcodeproj
#安装参考 https://www.jianshu.com/p/ed90f0c59104
#运行方式 cd到当前目录， 执行 ruby configXcodeproj.rb --liveRoom 或 ruby configXcodeproj.rb --expressEngine
        
require 'xcodeproj'


project_path = './go_class.xcodeproj'
project = Xcodeproj::Project.open(project_path)

target = nil
project.targets.each do |kTarget|
#    puts kTarget.name
    if kTarget.name == 'go_class'
        target = kTarget
    end
end

if target == nil
    raise "target:go_class 不存在"
end

#  清理工作
project.frameworks_group.files.each do |ref|
    if ref.name == "ZegoWhiteboardView.framework"
        ref.remove_from_project
        puts "remove #{ref.name}"
    end
end

dst_ref = nil
dst_ref = project.frameworks_group.new_file("./PodSDK/ZegoWhiteboardView.framework")
if dst_ref
    target.frameworks_build_phases.add_file_reference(dst_ref)
    puts "add #{dst_ref.name}"
end

# 清理多余的BuildFile文件
target.frameworks_build_phases.files.each do |file|
    if file.display_name == "BuildFile"
        file.remove_from_project
        puts "dele #{file.display_name}"
    end
end

#保存
project.save
puts 'save project'

puts "work completed"
