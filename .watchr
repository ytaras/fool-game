require 'rubygems'
# TODO Use libnotify
require 'gir_ffi'

# If your spec runner is at a different location: customize it here..
RSPEC_RUNNER = "bundle exec rspec" unless defined?(RSPEC_RUNNER)
JASMINE_RUNNER = "bundle exec jasmine-headless-webkit --color" unless defined?(JASMINE_RUNNER)

GirFFI.setup :Notify
Notify.init("Watchr")
#growl("Watchr started", "wachr started", "dialog-information")
# ---------
# Signals
# ---------

Signal.trap('QUIT') {
  run_all_specs(File.join(Dir.pwd, 'spec'))
  run_all_jasmine
} # Ctrl-\
Signal.trap('INT') { abort("\nBye.\n") } # Ctrl-C

# ---------
# Rules
# ---------

watch("spec/.*/*_spec.rb") do |md|
  run "Runnning: #{md[0]}" do
    `#{RSPEC_RUNNER} #{md[0]}`
  end
end

watch("app/(.*/.*).rb") do |match|
  spec = %{spec/#{match[1]}_spec.rb}
  if File.exist?(spec)
    run "Running: #{spec}" do
      `#{RSPEC_RUNNER} #{spec}`
    end
  end
end

watch("app/(.*/.*).coffee") do |match|
  run_all_jasmine
end

watch("spec/(.*/.*).coffee") do |match|
  run_jasmine match[0]
end

# ---------
# Helpers
# ---------

def run_jasmine(target)
  run "Running all in: #{target}", "jasmine" do
    `#{JASMINE_RUNNER} #{target}`
  end
end

def run_all_jasmine
  run_jasmine("spec/javascript")
end

def run_all_specs(target)
  run "Running all in: #{target}" do
    `#{RSPEC_RUNNER} #{target}`
  end
end


def run(description, runner = 'rspec', &block)
  puts "#{description}"

  result = parse_result(block.call, runner)

  if result[:tests] =~ /\d/
    if $?.success? && result[:success]
      title = "Specs Passed!"
      dialog_class = "dialog-information"
    else
      title = "Specs Failed!"
      dialog_class = "dialog-error"
    end

    specs_count = pluralize(result[:tests], "example", "examples")
    failed_count = pluralize(result[:failures], "failure", "failures")
    pending_count = pluralize(result[:pending], "pending", "pending")

    growl(title, "#{specs_count}, #{failed_count}, #{pending_count}", dialog_class)
  else
    growl("Running Specs Failed!", "Runner returned an error..")
  end
end

def pluralize(count, singular, plural)
  return "" if count.nil?
  count == "1" ? "#{count} #{singular}" : "#{count} #{plural}"
end

def growl(title, message, dialog_class = nil)

  notification = Notify::Notification.new(title, message, dialog_class)
  notification.show
end

def parse_result(result, runner)
  puts result
  send "parse_result_#{runner}", result

end

def parse_result_rspec(result)
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

def parse_result_jasmine(result)
  summary, tests, failures, duration = result.scan(/(\w+): (\d+) tests?, (\d+) failures?, (\d+.\d+) secs./).flatten
  {
      :tests => tests,
      :pending => 0,
      :failures => failures,
      :success => !summary.nil? && summary.end_with?("PASS"),
      :duration => duration
  }
end