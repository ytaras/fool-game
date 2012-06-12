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

    it "requires action" do
      login
      session[:game] = {}
      post :move, :format => 'json'
      response.status.should == 400
      response.body.should be_json 'error' => 'action should be provided'
    end
  end
end
