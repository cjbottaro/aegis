class User < ActiveRecord::Base
  has_role :hierarchy => { "Post" => "forum",
                           "Forum" => "account" },
           :force_superuser_if => Proc.new{ |user| user.is_admin? }
  validates_role_name

end
