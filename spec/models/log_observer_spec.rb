require 'spec_helper'

describe LogObserver do
  subject { LogObserver.new }
  context do
    before(:each) { 3.times { |x| subject.update(x) } }
    specify { should have(3).items }
    specify { should include(0, 1, 2) }
    specify { should_not be_empty }
    context 'when cleared' do
      before(:each) { subject.clear }
      specify { should have(0).items }
      specify { should be_empty }
    end

  end
end
