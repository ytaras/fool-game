RSpec::Matchers.define :be_json do |object|
  match do |string|
    ActiveSupport::JSON.decode(string) == object
  end

  failure_message_for_should do |string|
    "#{string} should be json of #{object.inspect}"
  end
end