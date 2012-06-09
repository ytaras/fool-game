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
  describe :create do
    include_examples "protected", :create

    it "redirects to play" do
      login
      get :create
      assigns[:game].should_not be_nil
    end
  end
end
