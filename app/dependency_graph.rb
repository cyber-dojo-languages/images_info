require 'json'

def dependency_graph(dependencies)
  if running_on_travis?
    key = ENV['TRAVIS_REPO_SLUG'].split('/')[1]
  else
    key = ENV['SRC_DIR']
  end
  root = dependencies[key].clone
  fill_dependency_graph(root, dependencies.clone)
  root
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def fill_dependency_graph(root, dependencies)
  root[:children] = {}
  dependencies.each do |dir,entry|
    if root[:image_name] == entry[:from]
      fill_dependency_graph(root[:children][dir] = entry.clone, dependencies)
    end
  end
end
