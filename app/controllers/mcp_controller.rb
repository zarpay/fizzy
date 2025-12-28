class McpController < ApplicationController
  skip_before_action :verify_authenticity_token
  disallow_account_scope

  def show
    head :method_not_allowed
  end

  def create
    method = params[:method]
    rpc_params = params[:params] || {}
    id = params[:id]

    result = case method
    when "initialize"
      handle_initialize
    when "notifications/initialized"
      # No response data needed for this notification
      {}
    when "tools/list"
      list_tools
    when "tools/call"
      call_tool(rpc_params["name"], rpc_params["arguments"] || {})
    else
      error_response("Method not found", -32601)
    end

    render json: { jsonrpc: "2.0", result: result, id: id }
  rescue => e
    render json: { jsonrpc: "2.0", error: { code: -32603, message: e.message }, id: id }
  end

  private

  def handle_initialize
    {
      protocolVersion: "2024-11-05",
      capabilities: {
        tools: {}
      },
      serverInfo: {
        name: "Fizzy MCP",
        version: "1.0.0"
      }
    }
  end

  def list_tools
    {
      tools: [
        {
          name: "list_boards",
          description: "List all boards accessible to the user",
          inputSchema: {
            type: "object",
            properties: {},
            required: []
          }
        },
        {
          name: "show_board",
          description: "Show details of a specific board including columns and recent cards",
          inputSchema: {
            type: "object",
            properties: {
              id: { type: "string", description: "The ID of the board" }
            },
            required: [ "id" ]
          }
        },
        {
          name: "create_card",
          description: "Create a new card on a specific board",
          inputSchema: {
            type: "object",
            properties: {
              board_id: { type: "string", description: "The ID of the board" },
              title: { type: "string", description: "The title of the card" },
              description: { type: "string", description: "The description of the card (optional)" },
              column_id: { type: "string", description: "The ID of the column to place the card in (optional)" }
            },
            required: [ "board_id", "title" ]
          }
        },
        {
          name: "close_card",
          description: "Close a card (archive it)",
          inputSchema: {
            type: "object",
            properties: {
              id: { type: "string", description: "The ID of the card" }
            },
            required: [ "id" ]
          }
        }
      ]
    }
  end

  def call_tool(name, arguments)
    case name
    when "list_boards"
      { content: [ { type: "text", text: JSON.pretty_generate(list_boards) } ] }
    when "show_board"
      { content: [ { type: "text", text: JSON.pretty_generate(show_board(arguments["id"])) } ] }
    when "create_card"
      { content: [ { type: "text", text: JSON.pretty_generate(create_card(arguments)) } ] }
    when "close_card"
      { content: [ { type: "text", text: JSON.pretty_generate(close_card(arguments["id"])) } ] }
    else
      raise "Tool not found: #{name}"
    end
  end

  def list_boards
    boards = Current.identity.users.includes(:account).flat_map do |user|
      user.boards.map do |board|
        {
          id: board.id,
          name: board.name,
          account_id: board.account.id,
          account_name: board.account.name
        }
      end
    end
    boards
  end

  def show_board(id)
    board = find_accessible_board(id)
    return { error: "Board not found or inaccessible" } unless board

    {
      id: board.id,
      name: board.name,
      description: board.public_description&.to_plain_text,
      columns: board.columns.includes(:cards).map do |col|
        {
          id: col.id,
          name: col.name,
          cards: col.cards.open.limit(50).map { |c| { id: c.id, title: c.title } }
        }
      end
    }
  end

  def create_card(args)
    board = find_accessible_board(args["board_id"])
    return { error: "Board not found or inaccessible" } unless board

    setup_context(board)

    column = if args["column_id"]
      board.columns.find_by(id: args["column_id"])
    else
      board.columns.first
    end

    card = board.cards.create!(
      title: args["title"],
      description: args["description"],
      column: column,
      creator: Current.user
    )

    {
      id: card.id,
      title: card.title,
      url: Rails.application.routes.url_helpers.card_url(card, host: "fizzy.localhost")
    }
  rescue => e
    { error: e.message }
  end

  def close_card(id)
    card = Card.find_by(id: id)
    return { error: "Card not found" } unless card

    board = card.board
    return { error: "Unauthorized" } unless accessible?(board)

    setup_context(board)

    card.close

    if card.reload.closed?
      { status: "success", message: "Card #{id} closed" }
    else
      { error: "Failed to close card" }
    end
  rescue => e
    { error: e.message }
  end

  def find_accessible_board(id)
    board = Board.find_by(id: id)
    return nil unless board
    return nil unless accessible?(board)
    board
  end

  def accessible?(board)
    user = Current.identity.users.find_by(account: board.account)
    return false unless user
    board.accessible_to?(user)
  end

  def setup_context(board)
    Current.account = board.account
    Current.user = Current.identity.users.find_by(account: board.account)
  end

  def error_response(message, code)
    { error: { code: code, message: message } }
  end
end
