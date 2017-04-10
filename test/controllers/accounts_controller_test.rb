require 'test_helper'

class AccountsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:one)
    @account = accounts(:one)
  end

  test "should get index" do
    get accounts_url
    assert_response :success
  end

  test "should get new" do
    get new_account_url
    assert_response :success
  end

  test "should create account" do
    assert_difference('Account.count') do
      post accounts_url, params: { account: { name: 'Purchased', code: 'purchased', description: 'description' } }
    end

    assert_redirected_to accounts_url
  end

  test "should show account" do
    get account_url('en',@account)
    assert_response :success
  end


  test "should get edit" do
    get edit_account_url('en',@account)
    assert_response :success
  end


  test "should update account" do
    patch account_url('en', @account), params: { account: { name: 'Updated Name' } }
    assert_redirected_to accounts_url

  end

  test "should destroy account" do
    assert_difference('Account.count', -1) do
      delete account_url('en',@account)
    end

    assert_redirected_to accounts_url
  end

end
