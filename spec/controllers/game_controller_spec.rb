require 'spec_helper'

describe GameController do
  shared_examples "protected" do |method|
    it "redirects to login" do
      get method
      response.should redirect_to new_user_session_path
    end
  end
  describe :create do
    include_examples "protected", :create
  end
end
