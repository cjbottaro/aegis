class Account < ActiveRecord::Base
  has_many :forums
end