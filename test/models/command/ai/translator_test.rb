require "test_helper"

class Command::Ai::TranslatorTest < ActionDispatch::IntegrationTest
  test "sandbox list of cards" do
    @url = cards_url

    test_command "tag cards assigned to jz with design"
    # test_command "summarize cards about performance"
    # test_command "tag with #performance"
    # test_command "cards assigned to jorge"
    # test_command "performance cards assigned to jorge"
    # test_command "close performance cards assigned to jorge and tag them with #performance"
  end

  test "sandbox single card" do
    @url = card_url(cards(:logo))

    test_command "summarize cards about performance"
    test_command "tag with performance and close"
    test_command "summarize this card"
    test_command "tag with #performance"
    test_command "cards assigned to jorge"
    test_command "performance cards assigned to jorge"
    test_command "close performance cards assigned to jorge and tag them with #performance"
  end

  private
    def test_command(query)
      user = users(:david)
      context = Command::Parser::Context.new(user, url: @url)
      translator = Command::Ai::Translator.new(context)
      puts translator.translate(query)
    end
end
