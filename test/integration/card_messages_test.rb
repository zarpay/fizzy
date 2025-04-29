require "test_helper"

class CardMessagesTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as :kevin
  end

  test "messages system" do
    # Create a card
    post collection_cards_path(collections(:writebook))
    card = Card.last
    assert_equal 1, card.comments.count
    assert_predicate card.comments.last, :event_summary?
    assert_equal "created", card.comments.last.events.sole.action

    # Comment on it
    post collection_card_comments_path(collections(:writebook), card), params: { comment: { body: "Agreed." } }
    assert_equal 2, card.comments.count
    assert_predicate card.comments.last, :comment?
    assert_equal "Agreed.", card.comments.last.body

    # Assign it
    post collection_card_assignments_path(collections(:writebook), card), params: { assignee_id: users(:kevin).id }
    assert_equal 3, card.comments.count
    assert_predicate card.comments.last, :event_summary?
    assert_equal 1, card.comments.last.event_summary.events.count
    assert_equal "card_assigned", card.comments.last.events.last.action
  end
end
