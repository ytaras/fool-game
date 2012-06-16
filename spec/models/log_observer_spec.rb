require 'spec_helper'

describe LogObserver do
  before(:each) { @observer = LogObserver.new }

  subject { @observer }
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
  context 'when logging game events' do
    context 'when put and then beat' do
      before(:each) {
        @observer.update :action => :put, :card => 'a'
        @observer.update :action => :beat, :card => 'b'
      }
      subject { @observer.diff }
      its([:table]) { should include(:added => [%w(a b)]) }
      context 'when take cards from table' do
        before(:each) {
          @game = double('game')
          @observer.update :action => :take, :cards => %w(a b c)
        }
        its([:table]) { should include(:removed => %w(a b c)) }
        its([:table]) { subject[:added].should be_empty }
      end
    end
    context 'when beat than put' do
      before(:each) {
        @observer.update :action => :put, :card => 'a'
        @observer.clear
        @observer.update :action => :beat, :card => 'b'
        @observer.update :action => :put, :card => 'c'
      }
      subject { @observer.diff }
      its([:table]) { should include(:added => [[nil, 'b'], %w(c)]) }
    end
  end
end
