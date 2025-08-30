require 'xcodeproj'

# Open the project
project = Xcodeproj::Project.open('ios/Runner.xcodeproj')

# Get the main target
target = project.targets.find { |t| t.name == "Runner" }

# Clean all Swift file references from build phase
puts "Cleaning build phases..."
files_to_remove = []
target.source_build_phase.files.each do |file|
  if file.file_ref && file.file_ref.path
    path = file.file_ref.path
    name = file.file_ref.display_name
    if ['DynamicIslandManager.swift', 'LiveActivityManager.swift', 'NotificationService.swift', 'WidgetCreationAttributes.swift'].include?(name)
      files_to_remove << file
      puts "Marking for removal: #{name} (#{path})"
    end
  end
end

files_to_remove.each { |f| target.source_build_phase.remove_file_reference(f.file_ref) }

# Clean file references from groups
puts "\nCleaning file references..."
def clean_group(group, files_to_clean)
  group.files.delete_if do |file|
    if files_to_clean.include?(file.display_name)
      puts "Removing reference: #{file.display_name}"
      true
    else
      false
    end
  end
  
  group.groups.each { |g| clean_group(g, files_to_clean) }
end

files_to_clean = ['DynamicIslandManager.swift', 'LiveActivityManager.swift', 'NotificationService.swift', 'WidgetCreationAttributes.swift']
clean_group(project.main_group, files_to_clean)

# Now add files properly
puts "\nAdding files with correct paths..."

# Get or create Runner group
runner_group = project.main_group['Runner']

# Add Swift files to Runner group
swift_files = {
  'DynamicIslandManager.swift' => 'DynamicIslandManager.swift',
  'LiveActivityManager.swift' => 'LiveActivityManager.swift',
  'NotificationService.swift' => 'NotificationService.swift'
}

swift_files.each do |name, path|
  file_ref = runner_group.new_file(path)
  file_ref.path = path
  target.source_build_phase.add_file_reference(file_ref)
  puts "Added #{name}"
end

# Add Shared folder at project root level
shared_group = project.main_group['Shared'] || project.main_group.new_group('Shared')
shared_group.path = '../Shared'

# Add WidgetCreationAttributes to Shared
widget_file = shared_group.new_file('WidgetCreationAttributes.swift')
widget_file.path = 'WidgetCreationAttributes.swift'
target.source_build_phase.add_file_reference(widget_file)
puts "Added WidgetCreationAttributes.swift to Shared"

# Also add to Widget Extension target if it exists
widget_target = project.targets.find { |t| t.name == "AssetWorksWidgetExtension" }
if widget_target
  widget_target.source_build_phase.add_file_reference(widget_file)
  puts "Also added WidgetCreationAttributes.swift to Widget Extension"
end

# Save
project.save
puts "\nProject cleaned and fixed!"