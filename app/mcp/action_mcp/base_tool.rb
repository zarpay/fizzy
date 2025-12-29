require "json"

class ActionMcp::BaseTool
  def tool_title
    self.class.name.without("Tool").underscore
  end

  private
    def success
    end

    def failure
    end

    def response(text)
      { content: [ { type: "text", text: JSON.pretty_generate(text) } ] }
    end
end
