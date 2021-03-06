require "spec_helper"


describe "Links#show" do
  let!(:link_owner) { FactoryGirl.create(:user) }
  let!(:non_owner) { FactoryGirl.create(:user) }
  let!(:link) { FactoryGirl.create(:link, user: link_owner) }

  let!(:ui) { LinksShowPage.new( link_path link ) }


  describe "the page contents" do
    context "when not logged in" do
      before { ui.visit_page }

      it { expect(page).to have_content link.title }
      it { expect(ui).not_to have_delete_button_for_link }
      it { expect(ui).not_to have_edit_button_for_link }
      it { expect(ui).not_to have_comment_form }
    end


    context "when logged in as someone who's not the link owner" do
      before { ui.visit_page_as non_owner }

      it { expect(ui).not_to have_delete_button_for_link }
      it { expect(ui).not_to have_edit_button_for_link }
    end


    context "when logged in as the link_owner" do
      before { ui.visit_page_as link_owner }

      it { expect(ui).to have_delete_button_for_link }
      it { expect(ui).to have_edit_button_for_link }
    end
  end


  #functionality
  it "upvoting as the link owner" do
    ui.visit_page_as link_owner

    expect{ ui.click_upvote_button_for(link) }.to(
      change { link.get_upvotes.size }.by(1))
  end


  it "downvoting as the link owner" do
    ui.visit_page_as link_owner

    expect{ ui.click_downvote_button_for(link) }.to(
      change { link.get_downvotes.size }.by(1))
  end


  it "upvoting as the someone who is not the link owner" do
    ui.visit_page_as non_owner

    expect{ ui.click_upvote_button_for(link) }.to(
      change { link.get_upvotes.size }.by(1))
  end


  it "downvoting as the someone who is not the link owner" do
    ui.visit_page_as non_owner

    expect{ ui.click_downvote_button_for(link) }.to(
      change { link.get_downvotes.size }.by(1))
  end

  it "has a working vote tally" do
    ui.visit_page_as(nil)

    expect(ui).to have_tally_for link
  end

  it "can add comments when logged in" do
    attrs = FactoryGirl.attributes_for(:comment, 
                                       comment: "blah",
                                       user: link_owner)
    ui.visit_page_as(link_owner)

    expect{ ui.create_comment(attrs) }
      .to change{link_owner.comments.count}.by(1)
  end

  describe "comment layout" do
    let!(:comment_attributes) { FactoryGirl.attributes_for(:comment, 
                                                :user => link_owner) }
    before do
      ui.visit_page_as(link_owner)
    end

    it "should have the comment" do
      comment = ui.create_comment(comment_attributes)

      expect(page).to have_content comment.comment
    end


    it "should have the name of the commenter" do
      comment = ui.create_comment(comment_attributes)

      expect(ui).to have_comment_author_name
    end
  end

  it "should have a delete comment button when user is comment owner" do
    ui.visit_page_as(link_owner)

    comment = ui.create_comment(
      FactoryGirl.attributes_for(:comment, user: link_owner) )

    expect(ui).to have_delete_button_for_comment(comment)
  end

  it "should not have a delete comment button when logged in as
  a non-comment owner" do
    ui.visit_page_as(link_owner)

    comment = ui.create_comment(
      FactoryGirl.attributes_for(:comment, user: link_owner) )

    ui.visit_page_as(non_owner)

    expect(ui).not_to have_delete_button_for_comment(comment)
  end

  it "should delete comment when delete button is clicked" do
    ui.visit_page_as(link_owner)
    comment = ui.create_comment_by(link_owner)

    expect {ui.click_delete_button_for_comment(comment)}
      .to change{ link_owner.comments.count }.by(-1)
  end
end
