class CreateCardTool < ApplicationTool
  def tool_description
    "Create a published card on a board"
  end

  def tool_schema
    {
      type: "object",
      properties: {
        board_id: { type: "string", description: "Board UUID" },
        title: { type: "string", description: "Card title" },
        description: { type: "string", description: "Optional rich text body" }
      },
      required: [ "board_id", "title" ]
    }
  end

  def call(args)
    Current.user = User.last
    board = Board.find(args["board_id"])
    card = board.cards.create!(
      title: args["title"],
      description: args["description"]
    )

    card.publish

    {
      id: card.id,
      title: card.title,
      url: Rails.application.routes.url_helpers.card_url(card, host: "fizzy.localhost")
    }
  end
end
