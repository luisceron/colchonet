class HomeController < ApplicationController
  def index
    @rooms = Room.most_recent.take(10)
    User.verifyConfirmedEmails()
  end
end