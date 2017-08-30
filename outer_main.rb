#!/usr/bin/env ruby

def my_dir
  File.dirname(__FILE__)
end

def space
  ' '
end

def success
  0
end

def assert_system(command)
  # does show command's interactive output but
  # does not show the command in failed diagnostic
  # because it contains DOCKER_PASSWORD
  system(command)
  status = $?.exitstatus
  unless status == success
    failed [ "exit_status == #{status}" ]
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def failed(lines)
  log(['FAILED'] + lines)
  exit 1
end

def log(lines)
  print(lines, STDERR)
end

def print(lines, stream)
  lines.each { |line| stream.puts line }
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def env_var(name)
  value = ENV[name]
  "-e #{name}=#{value}"
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

assert_system [
    'docker-compose',
      "--file #{my_dir}/docker-compose.yml",
      'run',
        env_var('DOCKER_USERNAME'),
        env_var('DOCKER_PASSWORD'),
        env_var('GITHUB_TOKEN'),
        env_var('SRC_DIR'),
        env_var('TRAVIS'),
        env_var('TRAVIS_REPO_SLUG'),
          'image_builder_inner',
            '/app/inner_main.rb',
    ].join(space) + ' ' + ARGV.join(space)
