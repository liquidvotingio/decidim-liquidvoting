# frozen_string_literal: true

require "spec_helper"

describe "Supporting an Assembly Proposal", type: :system do
  let(:organization) { create(:organization) }
  let(:assembly) { create(:assembly, organization: organization) }
  let(:assembly_proposals_component) { create(:component, participatory_space: assembly, manifest_name: :proposals) }
  let(:assembly_proposal) { create :proposal, component: assembly_proposals_component }

  let(:user) { create(:user, :confirmed, organization: organization) }

  def visit_assembly_proposal
    visit resource_locator(assembly_proposal).path
  end

  before do
    expect(assembly_proposal.component.participatory_space_type).to eq("Decidim::Assembly")

    login_as user, scope: :user
    visit_assembly_proposal
  end

  it "works" do
    click_button("Support", id: "vote_button-#{assembly_proposal.id}")

    expect(page).to have_button("Already supported")
    expect(page).not_to have_select("delegate_id")
    expect(page).to have_button("Delegate Support", disabled: true)
  end
end
