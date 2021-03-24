# frozen_string_literal: true

require "spec_helper"

describe "Supporting and Delegating a Proposal", type: :system do
  include_context "with a component"
  let!(:component) do
    create(
      :proposal_component,
      :with_votes_enabled,
      participatory_space: participatory_space
    )
  end

  let!(:proposal) { create :proposal, component: component }

  def visit_proposal
    visit resource_locator(proposal).path
  end

  context "when the user is not logged in" do
    before do
      visit_proposal
    end

    it "shows a support button" do
      expect(page).to have_button("Support")
    end

    it "does not show a delegation UI" do
      expect(page).to_not have_select("delegate_email")
      expect(page).to_not have_button("Delegate Support")
    end
  end

  context "when the user is logged in" do
    let!(:user) { create(:user, :confirmed, organization: organization) }
    let!(:delegate) { create(:user, :confirmed, organization: organization) }

    before do
      login_as user, scope: :user
    end

    context "and has not yet supported or delegated" do
      before do
        visit_proposal
      end

      it "shows a support button" do
        expect(page).to have_button("Support", id: "vote_button-#{proposal.id}", disabled: false)
      end

      context "and the user then supports" do
        let(:proposal_url) { Decidim::ResourceLocatorPresenter.new(proposal).url }
        let(:voting_result) { double }

        it "calls LV api create_vote" do
          expect(Decidim::Liquidvoting::Client).to receive(:create_vote).
          with(
            proposal_url: proposal_url,
            participant_email: user.email,
            yes: true
          ).
          and_return(voting_result)

          click_button("Support", id: "vote_button-#{proposal.id}")
        end
      end

      it "shows a delegation UI" do
        expect(page).to have_select("delegate_email")
        expect(page).to have_button("Delegate Support", disabled: false)
      end

      context "and the user then delegates"
    end

    context "and the proposal has been supported" do
      before do
        visit_proposal
        click_button("Support", id: "vote_button-#{proposal.id}")
      end

      it "shows an unsupport button" do
        expect(page).to have_button("Already supported", id: "vote_button-#{proposal.id}", disabled: false)
      end

      it "shows a disabled delegation UI" do
        expect(page).to_not have_select("delegate_email")
        expect(page).to have_button("Delegate Support", disabled: true)
      end
    end

    context "and the proposal has been delegated" do
      before do
        visit_proposal
        select delegate.name, from: "delegate_email"
        click_button "Delegate Support"
      end

      it "shows a disabled support button" do
        expect(page).to have_button("Support", id: "vote_button-#{proposal.id}", disabled: true)
      end

      it "shows a delegated UI" do
        expect(page).to_not have_select("delegate_email")
        # have text for delegated to delegate.name
        expect(page).to have_button("Withdraw Delegation")
      end
    end
  end
end