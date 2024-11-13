module FiltersHelper
  def filter_chip_id(value, name)
    "#{name}_filter--#{value}"
  end

  def filter_chips(filter, terms, **)
    filters = filter.to_h.map do |kind, object|
      filter_button_from kind, object, **
    end

    terms = Array.wrap(terms).map do |term|
      filter_button_from :terms, term, **
    end

    safe_join filters + terms
  end

  def filter_chip_tag(display:, value:, name:, **options)
    tag.button id: filter_chip_id(value, name),
        class: [ "btn txt-small btn--remove", options.delete(:class) ],
        data: { action: "filter-form#removeFilter form#submit", filter_form_target: "button" } do
      concat hidden_field_tag(name, value, id: nil)
      concat tag.span(display)
      concat image_tag("close.svg", aria: { hidden: true }, size: 24)
    end
  end

  def button_to_filter(text, kind:, object:, data: {})
    if object
      button_to text, filter_chips_path, method: :post, class: "btn btn--plain filter__button", params: filter_attrs(kind, object), data: data
    else
      button_tag text, type: :button, class: "btn btn--plain filter__button", data: data
    end
  end

  private
    def filter_button_from(kind, object, **)
      if object.respond_to? :map
        safe_join object.map { |o| filter_chip_tag(**filter_attrs(kind, o), **) }
      else
        filter_chip_tag(**filter_attrs(kind, object), **)
      end
    end

    def filter_attrs(kind, object)
      case kind&.to_sym
      when :tags
        [ object.hashtag, object.id, "tag_ids[]" ]
      when :buckets
        [ "in #{object.name}", object.id, "bucket_ids[]" ]
      when :assignees
        [ "for #{object.name}", object.id, "assignee_ids[]" ]
      when :assigners
        [ "by #{object.name}", object.id, "assigner_ids[]" ]
      when :indexed_by
        [ object.humanize, object, "indexed_by" ]
      when :assignments
        [ object.humanize, object, "assignments" ]
      when :terms
        [ %Q("#{object}"), object, "terms[]" ]
      end.then do |display, value, name|
        { display: display, value: value, name: name }
      end
    end
end
