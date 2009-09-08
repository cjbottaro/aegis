require "test/test_helper"

class HasRoleTest < ActiveSupport::TestCase

  context "Objects that have an aegis role" do

    setup do 
      @guest = User.new(:role_name => "guest")
      @student = User.new(:role_name => "student")
      @admin = User.new(:role_name => "admin")
    end
    
    should "know their role" do
      assert :guest, @guest.role.name
      assert :student, @student.role.name
      assert :admin, @admin.role.name
    end
    
    should "know if they belong to a role" do
      assert @guest.guest?
      assert !@guest.student?
      assert !@guest.admin?
      assert !@student.guest?
      assert @student.student?
      assert !@student.admin?
      assert !@admin.guest?
      assert !@admin.student?
      assert @admin.admin?
    end
    
    should "still behave as usual when a method ending in a '?' does not map to a role query" do
      assert_raise NoMethodError do
        @guest.nonexisting_method?
      end
    end
    
  end
  
  def test_role_in
    create_role_assignments
    user = users(:with_hierarchy)
    do_test_role_in(user)
  end
  
  def test_role_in_using_hierarchy_accessor
    create_role_assignments
    saved_role_heirarchy = User.aegis_role_hierarchy
    
    assert_not_nil User.aegis_role_hierarchy
    User.instance_variable_set("@aegis_role_hierarchy", nil)
    assert_nil User.aegis_role_hierarchy
    
    User.instance_variable_set("@aegis_role_hierarchy_accessor", "parent")
    assert_equal "parent", User.aegis_role_hierarchy_accessor
    
    do_test_role_in(users(:with_hierarchy))
    
    # So the rest of the tests don't break.
    User.instance_variable_set("@aegis_role_hierarchy", saved_role_heirarchy)
    User.instance_variable_set("@aegis_role_hierarchy_accessor", nil)
  end
  
  def test_forced_role
    create_role_assignments
    user = users(:with_hierarchy)
    user.update_attribute(:is_admin, true)
    assert_equal :superuser, user.role.name
    assert_equal :superuser, user.role_in(accounts(:google)).name
    assert_equal :superuser, user.role_in(forums(:searching)).name
    assert_equal :superuser, user.role_in(posts(:searching101)).name
    assert_equal :superuser, user.role_in(posts(:searching102)).name
  end
  
private
  
  def do_test_role_in(user)
    assert_equal :admin, user.role_in(accounts(:google)).name
    
    assert_equal :writer, user.role_in(forums(:searching)).name
    assert_equal :writer, user.role_in(posts(:searching101)).name
    assert_equal :reader, user.role_in(posts(:searching102)).name
    
    assert_equal :admin, user.role_in(forums(:crawling)).name
    assert_equal :admin, user.role_in(posts(:crawling101)).name
    assert_equal :admin, user.role_in(posts(:crawling102)).name
  end
  
end
