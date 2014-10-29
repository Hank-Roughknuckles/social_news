require "spec_helper"

describe "Links#show" do
  let!(:ui) { LinksShowPage.new }

  context "when logged in as the owner" do
    let!(:owner) { FactoryGirl.create(:user) }
    let!(:link) { FactoryGirl.create(:link, user: owner) }

    before do
      login_as(owner)
      visit link_path link
    end

    it { expect(ui).to have_delete_button_for_link }
      
  end
end