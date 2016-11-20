#
# Script to build README.md files from JSON files
# You might need the "json" gem to run it
#
require 'pathname'
unless require 'json'
	puts 'You need to install the json gem !'
	exit
end

class String
    def is_i?
       /\A[-+]?\d+\z/ === self
    end
end

MAIN_DIR = '../'
UNITS_JSON = MAIN_DIR + '/units.json'
MAIN_README = MAIN_DIR + '/README.md'

# A unit is in its JSON representation, with the "path" member holding the path to the unit
units = {}

# Detect all units, and get various information
define_method :build_units do
	
	# Units
	dirs = Dir[MAIN_DIR + '*'].select{|f| File.directory? f}.select{|f| File.basename(f)[0..1].is_i?}
	puts 'Detected units:'
	puts dirs
	
	dirs.each do |dir|
		if File.exists?(dir + '/unit.json')
			unit = JSON.parse(File.read(dir + '/unit.json'))
			unit['path'] = dir
			units[unit['unit']] = unit
		end
	end
end

# Create the README.md file for a unit
def create_unit_readme(unit)

	# Title
	out = "# Unit #{unit['unit'].to_s}: #{unit['title']}\n"
	
	# Description
	out << unit['description'].join("\n") << "\n\n"
	
	# Prerequisites
	if unit['prerequisites'] && unit['prerequisites'].class == Array && unit['prerequisites'].size > 0
		out << "## Prerequisites\n"
		unit['prerequisites'].each do |u|
			out << "- Unit #{u}: #{get_unit_path(u, unit['path'])}\n"
		end
	end
	
	# Save file
	File.open(unit['path'] + '/README.md', 'w') do |file|
		file.write(out)
	end
	
end

# Create the main README.md file
define_method :create_main_readme do

	# Header
	out = JSON.parse(File.read(UNITS_JSON))['header'].join("\n") + "\n"
	
	# Units
	units.each do |k, u|
		out << "#{k}. #{get_unit_path(u["unit"], MAIN_DIR)}\n"
	end
	
	# Save file
	File.open(MAIN_README, 'w') do |file|
		file.write(out)
	end
end

# Get unit path
define_method :get_unit_path do |unit_id, curr_path|

	unit = units[unit_id]
	if unit
		curr = Pathname.new(curr_path)
		unit_path = Pathname.new(unit['path'])
		out = "[#{unit['title']}](#{unit_path.relative_path_from(curr)})"
		if unit['short_description'] != ''
			out << " (#{unit['short_description']})"
		end
		out
	else
		'<?>'
	end
end

#
# MAIN
#

build_units
create_main_readme
units.each do |k, u|
	create_unit_readme u
end