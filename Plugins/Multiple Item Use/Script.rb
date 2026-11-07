module MultipleItemUse
  class ScreenAdapter
    def initialize(screen)
      @screen = screen
    end

    def show_message(message, &block)
      return @screen.show_message(message, &block) if @screen.respond_to?(:show_message)
      return @screen.pbDisplay(message, &block) if @screen.respond_to?(:pbDisplay)
      pbMessage(message, &block)
    end

    def show_confirm_message(message)
      return @screen.show_confirm_message(message) if @screen.respond_to?(:show_confirm_message)
      return @screen.pbConfirm(message) if @screen.respond_to?(:pbConfirm)
      pbConfirmMessage(message)
    end

    def choose_number(message, maximum)
      return @screen.choose_number(message, maximum) if @screen.respond_to?(:choose_number)
      params = ChooseNumberParams.new
      params.setRange(1, maximum)
      params.setInitialValue(1)
      params.setCancelValue(0)
      pbChooseNumber(message, params)
    end

    def refresh
      return @screen.refresh if @screen.respond_to?(:refresh)
      @screen.pbRefresh if @screen.respond_to?(:pbRefresh)
    end

    def refresh_party
      return @screen.refresh_party if @screen.respond_to?(:refresh_party)
      refresh
    end

    def update
      return @screen.update if @screen.respond_to?(:update)
      @screen.pbUpdate if @screen.respond_to?(:pbUpdate)
    end

    def set_help_text(text)
      return @screen.set_help_text(text) if @screen.respond_to?(:set_help_text)
      @screen.pbSetHelpText(text) if @screen.respond_to?(:pbSetHelpText)
    end

    def method_missing(name, *args, &block)
      return @screen.public_send(name, *args, &block) if @screen.respond_to?(name)
      super
    end

    def respond_to_missing?(name, include_private = false)
      @screen.respond_to?(name, include_private) || super
    end
  end
end

def pbBagUseItem(bag, item, scene, screen, chosen, bagscene = nil)
  pokemon = $player.party[chosen] if chosen && chosen >= 0
  return 0 unless pokemon && !pokemon.egg? && bag.has?(item)
  item_data = GameData::Item.get(item)
  return 0 unless item_data.is_machine? || item_data.field_use == 1
  adapter = if screen.respond_to?(:show_message) && screen.respond_to?(:choose_number)
              screen
            else
              MultipleItemUse::ScreenAdapter.new(screen)
            end
  previous_bag = $bag
  begin
    $bag = bag
    pbUseItemOnPokemon(item, pokemon, adapter)
  ensure
    $bag = previous_bag
  end
  adapter.refresh
  adapter.update
  bagscene.pbRefresh if bagscene && bagscene.respond_to?(:pbRefresh)
  1
end
