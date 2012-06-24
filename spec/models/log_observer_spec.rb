require 'spec_helper'

describe LogObserver do
  before(:each) { @observer = LogObserver.new }

  subject { @observer }
  context do
    before(:each) { 3.times { |x| subject.update({:x => x}) } }
    specify { should have(3).items }
    its('to_a') { should == [{:x => 0}, {:x => 1}, {:x => 2}] }
    specify { should_not be_empty }
    context 'when cleared' do
      before(:each) { subject.clear }
      specify { should have(0).items }
      specify { should be_empty }
    end
  end

  context 'when within a block' do
    before(:each) {
      @game = Game.create_game(Array.new(Game::SORTED_DECK))
      @card = @game.player2_cards.first
      @game.put(@card).should be_true
      @result = @observer.watch_diff(@game) do |obj|
        obj.take
      end
    }
    subject { @observer }
    specify { should be_empty }
    specify { @result[:table].should_not include(:added) }
    specify { @result[:table].should include(:removed => [@card]) }
  end
  context 'when logging game events' do
    context 'when put and then beat' do
      before(:each) {
        game = OpenStruct.new(:current_move => :player1)
        @observer.update :event => :put, :card => 'a', :game => game
        @observer.update :event => :beat, :card => 'b', :game => game
      }
      subject { @observer.diff }
      its([:table]) { should include(:added => [%w(a b)]) }
      its([:hand]) { should include(:removed => %w(a)) }

      context 'when take cards from table' do
        before(:each) {
          game = OpenStruct.new(:current_move => :player2)
          @observer.update :event => :take, :cards => %w(a b c), :game => game
        }
        its([:table]) { should include(:removed => %w(a b c)) }
        its([:table]) { subject[:added].should be_empty }
        its([:hand]) { should include(:added => %w(a b c)) }
      end
    end
    context 'when beat than put' do
      before(:each) {
        game = OpenStruct.new(:current_move => :player2)
        @observer.update :event => :put, :card => 'a', :game => game
        @observer.clear
        @observer.update :event => :beat, :card => 'b', :game => game
        @observer.update :event => :put, :card => 'c', :game => game
      }
      subject { @observer.diff }
      its([:table]) { should include(:added => [[nil, 'b'], %w(c)]) }
      its([:hand]) { should include(:removed => %w(b)) }
    end
    context 'when take cards from deck' do
      before(:each) {
        @observer.update :event => :next_move, :cards => %w(a b c)
      }
      subject { @observer.diff }
      its([:hand]) { should include(:added => %w(a b c)) }
    end

    context 'when discard cards from table' do
      before(:each) {
        game = OpenStruct.new(:current_move => :player2)
        @observer.update :event => :beat, :card => :x, :game => game
        @observer.update :event => :dismiss, :cards => %w(a b c)
        @observer.update :event => :next_move, :cards => %w(e f g)
        @observer.update :event => :put, :card => :h, :game => game
      }
      subject { @observer.diff }
      its([:hand]) { should include(:added => %w(e f g)) }
      its([:hand]) { should include(:removed => [:x]) }
      its([:table]) { should include(:added => [[nil, :x], [:h]]) }
      its([:table]) { should include(:removed => %w(a b c)) }
    end
    context 'when game ends' do
      before(:each) {
        @observer.update :event => :end, :winner => :player1
      }
      subject { @observer.diff }
      its([:winner]) { should be_true }
    end
  end
end
