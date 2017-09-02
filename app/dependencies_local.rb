require 'json'

def local_dependencies
  # I should be able to use Dir.glob() but I can't get it to work.
  triples = {}
  src_dir = ENV['SRC_DIR']
  base_dir = File.expand_path("#{src_dir}/..", '/')
  Dir.entries(base_dir).each do |entry|
    #print '.'
    dir = base_dir + '/' + entry
    args = dir_get_args(dir)
    unless args.nil?
      triples[entry] = args
    end
  end
  triples
end

def dir_get_args(dir)
  get_args(dir) { |filename| read_nil(filename) }
end

def read_nil(filename)
  File.exists?(filename) ? IO.read(filename) : nil
end

def get_args(dirname)
  docker_filename = dirname + '/docker/Dockerfile'
  dockerfile = yield(docker_filename)
  if dockerfile.nil?
    return nil
  end
  args = []
  args << (image_name_filename = dirname + '/docker/image_name.json')
  args << (manifest_filename   = dirname + '/start_point/manifest.json')
  args << (image_name_file = yield(image_name_filename))
  args << (manifest_file   = yield(manifest_filename))
  {
    from:get_FROM(dockerfile),
    image_name:get_image_name(args),
    test_framework:get_test_framework(manifest_file)
  }
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def get_FROM(dockerfile)
  lines = dockerfile.split("\n")
  from_line = lines.find { |line| line.start_with? 'FROM' }
  from_line.split[1].strip
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def get_image_name(args)
  image_name_filename = args[0]
  manifest_filename   = args[1]
  image_name_file     = args[2]
  manifest_file       = args[3]

  either_or = [
    "#{image_name_filename} must exist",
    'or',
    "#{manifest_filename} must exist"
  ]

  image_name = !image_name_file.nil?
  manifest = !manifest_file.nil?

  if !image_name && !manifest
    failed either_or + [ 'neither do.' ]
  end
  if image_name && manifest
    failed either_or + [ 'but not both.' ]
  end
  if image_name
    file = image_name_file
  end
  if manifest
    file = manifest_file
  end
  JSON.parse(file)['image_name']
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def get_test_framework(file)
  !file.nil?
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def failed(lines)
  log(['FAILED'] + lines)
  exit 1
end

def log(lines)
  print_to(lines, STDERR)
end

def print_to(lines, stream)
  lines.each { |line| stream.puts line }
end
