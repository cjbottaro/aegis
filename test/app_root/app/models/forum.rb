class Forum < ActiveRecord::Base
  belongs_to :account
  has_many :posts
  
  def parent
    account
  end
end