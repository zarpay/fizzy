class Account::ServiceAccountsController < ApplicationController
  before_action :ensure_admin

  def create
    identity = Identity.find_or_create_by!(email_address: email_address)
    identity.join(Current.account, name: name)
    user = Current.account.users.find_by!(identity: identity)
    access_token = identity.access_tokens.create!(permission: :write, description: "Service account for #{user.name}")

    render json: { user: { id: user.id, name: user.name, role: user.role }, token: access_token.token }, status: :created
  end

  private
    def name
      params.expect(:name)
    end

    def email_address
      params[:email_address].presence || "#{name.parameterize}@service.localhost"
    end
end
