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
