# frozen_string_literal: true

require "spec_helper"

describe "Admin manages delegations", type: :system do
  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit Decidim::ActionDelegator::AdminEngine.routes.url_helpers.delegations_path
  end

  it "renders the delegations page" do
    expect(page).to have_content("index")
  end
end
