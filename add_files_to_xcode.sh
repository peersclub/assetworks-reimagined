#!/bin/bash

# Add Swift files to Xcode project using xcodeproj Ruby gem
# This script requires ruby and xcodeproj gem installed

echo "Installing xcodeproj gem if needed..."
gem list xcodeproj -i || sudo gem install xcodeproj

echo "Creating Ruby script to add files..."
cat > add_files.rb << 'EOF'
require 'xcodeproj'

# Open the project
project_path = 'ios/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.find { |t| t.name == "Runner" }

# Get the main group
main_group = project.main_group['Runner']

# Files to add
files_to_add = [
  'ios/Runner/DynamicIslandManager.swift',
  'ios/Runner/LiveActivityManager.swift',
  'ios/Runner/NotificationService.swift'
]

# Add each file
files_to_add.each do |file_path|
  file_name = File.basename(file_path)
  
  # Check if file already exists in project
  unless main_group.files.find { |f| f.display_name == file_name }
    # Add file reference
    file_ref = main_group.new_reference(file_path)
    
    # Add to build phase
    target.source_build_phase.add_file_reference(file_ref)
    
    puts "Added #{file_name} to project"
  else
    puts "#{file_name} already in project"
  end
end

# Add Shared folder
shared_path = 'ios/Shared'
if Dir.exist?(shared_path)
  shared_group = project.main_group.find_subpath('Shared', true)
  
  Dir.glob("#{shared_path}/*.swift").each do |file_path|
    file_name = File.basename(file_path)
    
    unless shared_group.files.find { |f| f.display_name == file_name }
      file_ref = shared_group.new_reference(file_path)
      target.source_build_phase.add_file_reference(file_ref)
      puts "Added #{file_name} to Shared group"
    end
  end
end

# Save the project
project.save
puts "Project saved successfully!"
EOF

echo "Running Ruby script..."
ruby add_files.rb

echo "Cleaning up..."
rm add_files.rb

echo "Files added to Xcode project!"
echo "Now you can build the project."