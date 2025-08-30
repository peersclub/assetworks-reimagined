require 'xcodeproj'

# Open the project
project = Xcodeproj::Project.open('ios/Runner.xcodeproj')

# Get targets
runner_target = project.targets.find { |t| t.name == "Runner" }

# Clean up all incorrectly added files first
puts "Cleaning up incorrect file references..."
runner_target.source_build_phase.files.delete_if do |file|
  if file.file_ref
    name = file.file_ref.display_name
    if ['DynamicIslandManager.swift', 'LiveActivityManager.swift', 'NotificationService.swift', 'WidgetCreationAttributes.swift'].include?(name)
      puts "Removing from build phase: #{name}"
      true
    end
  end
end

# Clean all groups
def clean_all_references(group, files_to_remove)
  group.files.delete_if do |file|
    if files_to_remove.include?(file.display_name)
      puts "Removing reference: #{file.display_name}"
      true
    end
  end
  group.groups.each { |g| clean_all_references(g, files_to_remove) }
end

files_to_remove = ['DynamicIslandManager.swift', 'LiveActivityManager.swift', 'NotificationService.swift', 'WidgetCreationAttributes.swift']
clean_all_references(project.main_group, files_to_remove)

# Remove Shared group if it exists
if shared_group = project.main_group['Shared']
  shared_group.remove_from_project
  puts "Removed Shared group"
end

# Now add files with correct configuration
puts "\nAdding files with correct paths..."

# Get Runner group
runner_group = project.main_group['Runner']

# Add Runner Swift files
runner_files = [
  'DynamicIslandManager.swift',
  'LiveActivityManager.swift', 
  'NotificationService.swift'
]

runner_files.each do |filename|
  file_ref = runner_group.new_file(filename)
  runner_target.source_build_phase.add_file_reference(file_ref)
  puts "Added #{filename} to Runner"
end

# Create Shared group at ios level
shared_group = project.main_group.new_group('Shared', 'Shared')

# Add WidgetCreationAttributes to Shared
widget_attrs_ref = shared_group.new_file('WidgetCreationAttributes.swift')
runner_target.source_build_phase.add_file_reference(widget_attrs_ref)
puts "Added WidgetCreationAttributes.swift to Shared"

# Save
project.save
puts "\nProject configuration complete!"
puts "Files have been properly added to the Xcode project."