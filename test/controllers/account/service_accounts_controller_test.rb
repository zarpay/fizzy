require "test_helper"

class Account::ServiceAccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as :kevin
  end

  test "create service account" do
    assert_difference -> { User.count } do
      post account_service_accounts_path, params: { name: "Agora Bot" }, as: :json
    end

    assert_response :created

    body = @response.parsed_body
    assert_equal "Agora Bot", body["user"]["name"]
    assert_equal "member", body["user"]["role"]
    assert body["token"].present?
  end

  test "create with custom email address" do
    post account_service_accounts_path, params: { name: "Deploy Bot", email_address: "deploy@bots.example.com" }, as: :json

    assert_response :created
    assert Identity.find_by(email_address: "deploy@bots.example.com")
  end

  test "create generates email from name when none provided" do
    post account_service_accounts_path, params: { name: "My Cool Bot" }, as: :json

    assert_response :created
    assert Identity.find_by(email_address: "my-cool-bot@service.localhost")
  end

  test "create for existing identity issues new token" do
    post account_service_accounts_path, params: { name: "First Bot", email_address: "bot@example.com" }, as: :json
    assert_response :created
    first_token = @response.parsed_body["token"]

    post account_service_accounts_path, params: { name: "First Bot", email_address: "bot@example.com" }, as: :json
    assert_response :created
    second_token = @response.parsed_body["token"]

    assert_not_equal first_token, second_token
  end

  test "create requires name" do
    assert_no_difference -> { User.count } do
      post account_service_accounts_path, params: {}, as: :json
    end

    assert_response :bad_request
  end

  test "non-admin cannot create service account" do
    logout_and_sign_in_as :david

    post account_service_accounts_path, params: { name: "Sneaky Bot" }, as: :json
    assert_response :forbidden
  end

  test "owner can create service account" do
    sign_in_as :jason

    assert_difference -> { User.count } do
      post account_service_accounts_path, params: { name: "Owner Bot" }, as: :json
    end

    assert_response :created
  end
end
