#!/usr/bin/env ruby

require_relative 'dependencies'

dependencies = get_dependencies
puts JSON.pretty_generate(dependencies)

#graph = dependency_graph(dependencies)
#puts JSON.pretty_generate(graph)
