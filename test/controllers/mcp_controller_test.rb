require "test_helper"

class McpControllerTest < ActionDispatch::IntegrationTest
  setup do
    integration_session.default_url_options[:script_name] = nil
    Current.account = nil
    @davids_token = identity_access_tokens(:davids_api_token).token
    @headers = { "Authorization" => "Bearer #{@davids_token}" }
    @david = users(:david)
    @board = boards(:writebook)
  end

  test "initialize handshake" do
    post mcp_path, params: {
      jsonrpc: "2.0",
      method: "initialize",
      params: {
        protocolVersion: "2024-11-05",
        capabilities: {},
        clientInfo: { name: "test-client", version: "1.0" }
      },
      id: 0
    }, as: :json, headers: @headers

    assert_response :success
    json = response.parsed_body
    assert_nil json["error"]

    result = json["result"]
    assert_equal "Fizzy MCP", result["serverInfo"]["name"]
    assert result["capabilities"].key?("tools")
  end

  test "tools/list returns available tools" do
    post mcp_path, params: {
      jsonrpc: "2.0",
      method: "tools/list",
      id: 1
    }, as: :json, headers: @headers

    assert_response :success
    json = response.parsed_body
    assert_nil json["error"]
    assert_equal 1, json["id"]

    tools = json["result"]["tools"]
    assert_kind_of Array, tools
    tool_names = tools.map { |t| t["name"] }
    assert_includes tool_names, "list_boards"
    assert_includes tool_names, "show_board"
    assert_includes tool_names, "create_card"
    assert_includes tool_names, "close_card"
  end

  test "list_boards returns accessible boards" do
    post mcp_path, params: {
      jsonrpc: "2.0",
      method: "tools/call",
      params: {
        name: "list_boards"
      },
      id: 2
    }, as: :json, headers: @headers

    assert_response :success
    json = response.parsed_body
    assert_nil json["error"]

    result = JSON.parse(json["result"]["content"].first["text"])
    assert_kind_of Array, result
    assert result.any? { |b| b["id"] == @board.id && b["name"] == @board.name }
  end

  test "show_board returns board details" do
    post mcp_path, params: {
      jsonrpc: "2.0",
      method: "tools/call",
      params: {
        name: "show_board",
        arguments: { id: @board.id }
      },
      id: 3
    }, as: :json, headers: @headers

    assert_response :success
    json = response.parsed_body
    assert_nil json["error"]

    result = JSON.parse(json["result"]["content"].first["text"])
    assert_equal @board.id, result["id"]
    assert_equal @board.name, result["name"]
    assert_kind_of Array, result["columns"]
  end

  test "create_card creates a new card" do
    assert_difference "Card.count" do
      post mcp_path, params: {
        jsonrpc: "2.0",
        method: "tools/call",
        params: {
          name: "create_card",
          arguments: {
            board_id: @board.id,
            title: "New MCP Card",
            description: "Created via MCP"
          }
        },
        id: 4
      }, as: :json, headers: @headers
    end

    assert_response :success
    json = response.parsed_body
    assert_nil json["error"]

    result = JSON.parse(json["result"]["content"].first["text"])
    assert result["id"].present?
    assert_equal "New MCP Card", result["title"]

    card = Card.find(result["id"])
    assert_equal "New MCP Card", card.title
    assert_equal "Created via MCP", card.description.to_plain_text
    assert_equal @david, card.creator
  end

  test "close_card closes a card" do
    # Create a card to close
    # We need to ensure context is set up correctly when creating the card fixture if we were doing it manually,
    # but here we are just using AR.
    # Note: Creating a card might fail if Current.account is nil and model callbacks rely on it.
    # But Card uses `belongs_to :account, default: -> { board.account }`.
    # Let's ensure we can create it.
    card = @board.cards.create!(title: "To Close", creator: @david, column: @board.columns.first)

    assert_not card.closed?

    post mcp_path, params: {
      jsonrpc: "2.0",
      method: "tools/call",
      params: {
        name: "close_card",
        arguments: { id: card.id }
      },
      id: 5
    }, as: :json, headers: @headers

    assert_response :success
    json = response.parsed_body
    assert_nil json["error"]

    result = JSON.parse(json["result"]["content"].first["text"])
    assert_equal "success", result["status"]

    assert card.reload.closed?
  end

  test "requires authentication" do
    post mcp_path, params: {
      jsonrpc: "2.0",
      method: "tools/list",
      id: 1
    }, as: :json

    # Default Rails behavior for unauthenticated access is redirect to login
    assert_response :redirect
    assert_redirected_to new_session_path
  end

  test "returns error for invalid tool" do
    post mcp_path, params: {
      jsonrpc: "2.0",
      method: "tools/call",
      params: {
        name: "non_existent_tool"
      },
      id: 6
    }, as: :json, headers: @headers

    assert_response :success # JSON-RPC errors are 200 OK mostly
    json = response.parsed_body
    assert json["error"].present?
    assert_equal -32603, json["error"]["code"] # or whatever I set generic errors to
  end
end
