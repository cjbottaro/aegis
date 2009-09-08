
class Permissions < Aegis::Permissions

  role :guest
  role :student
  role :admin, :default_permission => :allow
  role :superuser, :default_permission => :allow
  
  role :reader
  role :writer
  
  permission :use_empty do
  end
  
  permission :use_simple do
    allow :student
    deny :admin
  end

  permission :update_users do
    allow :student
    deny :admin
  end
  
  permission :crud_projects do
    allow :student
  end
  
  permission :edit_drinks do
    allow :student
    deny :admin
  end
  
  permission :hug do
    allow :everyone
  end
  
  permission :divide do |user, left, right|
    allow :student do
      right != 0
    end
  end
  
  permission :draw do
    allow :everyone
  end
  
  permission :draw do
    deny :student
    deny :admin
  end
  
  permission :edit_post do
    allow :writer
  end
  
  permission :view_post do
    allow :reader
    allow :writer
  end
  
  permission :create_post do
    context "Forum"
    allow :writer
  end
  
  permission :create_forum do
    allow :writer
  end
  
end
