class Post < ActiveRecord::Base
  belongs_to :forum
  
  def parent
    forum
  end
end