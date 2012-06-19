require 'spec_helper'

describe GameController do

  def login
    sign_in FactoryGirl.create(:user)
  end

  shared_examples "protected" do |path, method|
    it "redirects to login" do
      send method, path
      response.should redirect_to new_user_session_path
    end
  end

  shared_examples 'game structure' do
    context do
      subject { ActiveSupport::JSON.decode(response.body)['game'] }
      its(:keys) { should include('table', 'deck', 'cards', 'trumpCard', 'opponent', 'myMove') }
      specify { should have(6).items }
    end
  end
  describe :play do
    include_examples "protected", :play, :get

    it "creates game if not exists" do
      login
      get :play
      old_game = assigns[:game]
      old_game.should_not be_nil
      get :play
      assigns[:game].should === old_game
    end

    context 'when get json' do
      before(:each) {
        login
        get :play, :format => :json
      }
      subject { response }
      its(:status) { should == 200 }
      include_examples 'game structure'
    end
  end

  describe :move do
    include_examples "protected", :move, :post
    describe :ajax do
      before(:each) do
        login
      end

      it "requires action" do
        post :move, :format => 'json'
        response.status.should == 400
        response.body.should be_json 'error' => 'action should be provided'
      end

      it "doesnt allow wrong card" do
        post :move, :format => 'json', :move => 'put', :card => {:suit => 'A', :card => 'B'}
        response.status.should == 400
        ActiveSupport::JSON.decode(response.body).should have_key('error')
      end

      context 'when player first move' do
        before(:each) {
          session[:game] = controller.create_game Array.new(Game::SORTED_DECK)
          post :move, :format => 'json', :move => 'put', :card => {:suit => 'Heart', :card => '6'}
        }
        subject { ActiveSupport::JSON.decode(response.body) }

        context do
          subject { assigns[:game] }
          specify { subject.table.stacks.first.size.should == 1 }
        end
        # TODO Move to view spec
        its(['changes']) { should include('table') }
        include_examples 'game structure'
      end

      context 'when ai first move' do
        before(:each) {
          start_deck = Array.new(Game::SORTED_DECK).take(12)
          start_deck.push start_deck.shift
          session[:game] = controller.create_game start_deck
          post :move, :format => 'json', :move => 'beat', :card => {:suit => 'Spade', :card => '7'}
        }
        context do
          subject { assigns[:changes] }
          its(["table"]) { should_not be_nil }
          specify {
            subject['table']['added'].should == [[nil, Card.new(:Spade, :'7')], [Card.new(:Heart, :'7')]]
          }
        end
        include_examples 'game structure'
      end

      it "puts card on a table" do
        post :move, :format => 'json', :move => 'put', :card => {:suit => 'Heart', :card => '6'}
        ActiveSupport::JSON.decode(response.body)['game'].keys.map { |x| x.to_sym }.should =~
            [:table, :deck, :cards, :trumpCard, :opponent, :myMove]
      end

      it "beats card on a table" do
        post :move, :format => 'json', :move => 'beat', :card => {:suit => 'Heart', :card => '6'}
        ActiveSupport::JSON.decode(response.body)['game'].keys.map { |x| x.to_sym }.should =~
            [:table, :deck, :cards, :trumpCard, :opponent, :myMove]
      end
    end
  end
end
