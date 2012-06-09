require 'spec_helper'

describe GameController do

  def login
    sign_in FactoryGirl.create(:user)
  end

  shared_examples "protected" do |method|
    it "redirects to login" do
      get method
      response.should redirect_to new_user_session_path
    end
  end
  describe :play do
    include_examples "protected", :play

    it "creates game if not exists" do
      login
      get :play
      old_game = assigns[:game]
      old_game.should_not be_nil
      get :play
      assigns[:game].should === old_game
    end
  end
end
