require 'xcodeproj'

# Open the Xcode project
project_path = 'ios/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
main_target = project.targets.find { |t| t.name == 'Runner' }
runner_group = project.main_group.find_subpath('Runner', true)

# Check if GoogleService-Info.plist already exists in the project
google_service_file = runner_group.files.find { |f| f.path == 'GoogleService-Info.plist' }

unless google_service_file
  # Add GoogleService-Info.plist to the project
  file_ref = runner_group.new_reference('GoogleService-Info.plist')
  
  # Add to build phase
  main_target.resources_build_phase.add_file_reference(file_ref)
  
  puts "Added GoogleService-Info.plist to the project"
else
  puts "GoogleService-Info.plist already exists in the project"
end

# Save the project
project.save

puts "Project saved successfully"
