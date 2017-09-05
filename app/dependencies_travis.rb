# Currently UNUSED

require 'json'

def repo_dependencies
  triples = {}
  base_url = 'https://raw.githubusercontent.com/cyber-dojo-languages'
  get_repo_names.each do |repo_name|
    # eg repo_name = 'gplusplus-catch'
    #print '.'
    url = base_url + '/' + repo_name + '/' + 'master'
    args = get_args(url) { |filename| curl_nil(filename) }
    triples[repo_name] = args unless args.nil?
  end
  triples
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def get_repo_names
  # https://developer.github.com/v3/repos/#list-organization-repositories
  # important to use GITHUB_TOKEN in an authenticated request
  # so the github rate-limit is 5000 requests per hour. Non
  # authenticated rate-limit is only 60 requests per hour.
  github_token = ENV['GITHUB_TOKEN']
  if github_token.nil? || github_token == ''
    failed [ 'GITHUB_TOKEN env-var not set' ]
  end
  org_url = 'https://api.github.com/orgs/cyber-dojo-languages'
  command = [
    'curl',
    '--silent',
    "--user 'travisuser:#{github_token}'",
    "--header 'Accept: application/vnd.github.v3.full+json'",
    org_url + '/repos?per_page=1000'
  ].join(' ')
  response = `#{command}`
  json = JSON.parse(response)
  json.collect { |repo| repo['name'] }
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def curl_nil(url)
  command = [ 'curl', '--silent', '--fail', url ].join(' ')
  file = `#{command}`
  $?.exitstatus == 0 ? file : nil
end

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# common
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def dir_get_args(dir)
  get_args(dir) { |filename| read_nil(filename) }
end

def read_nil(filename)
  File.exists?(filename) ? IO.read(filename) : nil
end

def get_args(base)
  docker_filename = base + '/docker/Dockerfile'
  dockerfile = yield(docker_filename)
  if dockerfile.nil?
    return nil
  end
  args = []
  args << (image_name_filename = base + '/docker/image_name.json')
  args << (manifest_filename   = base + '/start_point/manifest.json')
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
