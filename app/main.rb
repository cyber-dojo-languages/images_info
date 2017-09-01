#!/usr/bin/env ruby

require_relative 'dependencies_local'

dependencies = local_dependencies
puts JSON.pretty_generate(dependencies)
