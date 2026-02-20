module BridgeHelper
  def bridge_icon(name)
    asset_url("#{name}.svg")
  end

  def bridged_button_to_board(board)
    link_to "Go to #{board.name}", board, hidden: true, data: {
      bridge__buttons_target: "button",
      bridge_icon_url: bridge_icon("board"),
      bridge_title: "Go to #{board.name}"
    }
  end
end
