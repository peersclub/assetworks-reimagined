require 'xcodeproj'

# Open the project
project = Xcodeproj::Project.open('ios/Runner.xcodeproj')

# Get the main target
target = project.targets.find { |t| t.name == "Runner" }

# Remove incorrectly added files
target.source_build_phase.files.delete_if do |file|
  if file.file_ref && file.file_ref.path
    path = file.file_ref.path
    if path.include?('ios/ios/') || path.include?('ios/Runner/ios/')
      puts "Removing incorrect path: #{path}"
      true
    end
  end
end

# Get the main group
main_group = project.main_group['Runner']

# Clean up file references
main_group.files.delete_if do |file|
  if file.path && (file.path.include?('ios/ios/') || file.path.include?('ios/Runner/'))
    puts "Removing incorrect reference: #{file.path}"
    true
  end
end

# Add files with correct paths
files_to_add = [
  ['DynamicIslandManager.swift', 'DynamicIslandManager.swift'],
  ['LiveActivityManager.swift', 'LiveActivityManager.swift'],
  ['NotificationService.swift', 'NotificationService.swift']
]

files_to_add.each do |file_name, file_path|
  # Check if file already exists
  unless main_group.files.find { |f| f.display_name == file_name }
    # Add file reference with relative path
    file_ref = main_group.new_file(file_path)
    
    # Add to build phase
    target.source_build_phase.add_file_reference(file_ref)
    
    puts "Added #{file_name} with correct path"
  end
end

# Handle Shared folder
shared_group = project.main_group.find_subpath('Shared', true) || project.main_group.new_group('Shared', '../Shared')

# Add WidgetCreationAttributes.swift
unless shared_group.files.find { |f| f.display_name == 'WidgetCreationAttributes.swift' }
  file_ref = shared_group.new_file('../Shared/WidgetCreationAttributes.swift')
  target.source_build_phase.add_file_reference(file_ref)
  puts "Added WidgetCreationAttributes.swift to Shared group"
end

# Save the project
project.save
puts "Project fixed and saved successfully!"