require 'rubygems'

# If your spec runner is at a different location: customize it here..
RUNNER = "bundle exec rspec" unless defined?(RUNNER)


# ---------
# Signals
# ---------

Signal.trap('QUIT') { run_all_specs(File.join(Dir.pwd, 'spec')) } # Ctrl-\
Signal.trap('INT') { abort("\nBye.\n") } # Ctrl-C

# ---------
# Rules
# ---------

watch("spec/.*/*_spec.rb") do |md|
  run "Runnning: #{md[0]}" do
    `#{RUNNER} #{md[0]}`
  end
end

watch("app/(.*/.*).rb") do |match|
  spec = %{spec/#{match[1]}_spec.rb}
  if File.exist?(spec)
    run "Running: #{spec}" do
      `#{RUNNER} #{spec}`
    end
  end
end


# ---------
# Helpers
# ---------

def run_all_specs(target)
  run "Running all in: #{target}" do
    `#{RUNNER} #{target}`
  end
end


def run(description, &block)
  puts "#{description}"

  result = parse_result(block.call)

  if result[:tests] =~ /\d/
    if $?.success? && result[:success]
      title = "Specs Passed!"
      img = "~/.watchr/success.png"
    else
      title = "Specs Failed!"
      img = "~/.watchr/failed.png"
    end

    specs_count = pluralize(result[:tests], "example", "examples")
    failed_count = pluralize(result[:failures], "failure", "failures")
    pending_count = pluralize(result[:pending], "pending", "pending")

    growl(title, "#{specs_count}, #{failed_count}, #{pending_count}", img)
  else
    growl("Running Specs Failed!", "Runner returned an error..")
  end
end

def pluralize(count, singular, plural)
  return "" if count.nil? || count.empty?
  count == "1" ? "#{count} #{singular}" : "#{count} #{plural}"
end

def growl(title, message, image_path = nil)
  image_path = File.expand_path(image_path) if image_path

  notify_send = "notify-send  '#{title}' '#{message}' "
  notify_send << "-i '#{image_path}' " if image_path && File.exists?(image_path)
  system notify_send
end

def parse_result(result)
  puts result
  duration = result.scan(/Finished in (\d.\d+) seconds/).flatten.first
  tests, failures, pending = result.scan(/(\d+) examples?, (\d+) failures?(?:, (\d+) pending?)?/).flatten
  {
      :tests => tests,
      :pending => pending,
      :failures => failures,
      :success => failures == "0",
      :duration => duration
  }
end