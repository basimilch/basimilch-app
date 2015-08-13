# # Inspired from: http://stackoverflow.com/a/677141

class Hash

  # Returns the value given a path of keys, without failing.
  # Inspired from: http://stackoverflow.com/a/10131410
  def get(*args)
    res = self
    args.each do |k|
      if res.try('include?',k)
        res = res[k]
      else
        return nil
      end
    end
    res
  end
end


class ActiveRecord::Base

  # Source: http://stackoverflow.com/a/7830624
  # Source: http://www.keenertech.com/articles/2011/06/26/
  #                                    recipe-detecting-required-fields-in-rails
  def required_attribute?(attribute)
    self.class.validators_on(attribute).map(&:class).include?(
      ActiveRecord::Validations::PresenceValidator)
  end
end


class ActionView::Helpers::FormBuilder

  # Full attribute type list.
  # Source: http://stackoverflow.com/a/3260466
  # Source: http://stackoverflow.com/a/15667038
  #
  # :binary
  # :boolean
  # :date
  # :datetime
  # :decimal
  # :float
  # :integer
  # :primary_key
  # :string
  # :text
  # :time
  # :timestamp

  INPUT_FIELD_TYPES = {
    string:   :text_field,
    text:     :text_area,
    boolean:  :check_box,
    password: :password_field
  }

  REQUIRED_ATTRIBUTE_MARK = '*'

  def input_type_for(attribute)
    INPUT_FIELD_TYPES[attribute] ||
      INPUT_FIELD_TYPES[object.column_for_attribute(attribute).type] ||
      :text_field
  end

  # Returns HTML for a form field with labels and proper configuration
  # using Bootstrap classes.
  # Consider: https://github.com/bootstrap-ruby/rails-bootstrap-forms ;)
  def field_for(attribute, options = {})
    is_view_mode  = self.options[:view_mode] == true
    input_type    = input_type_for(options[:real_attribute] || attribute)
    is_checkbox   = input_type == :check_box
    input_class   = ''
    input_class   << 'form-control' unless is_checkbox
    input_class   << ' view-mode'   if is_view_mode
    readonly      = options.include?(:readonly) ? options[:readonly] : false
    placeholder   = is_checkbox ? '' : I18n.t("activerecord.placeholders." +
                                     "#{object.class.name.downcase}." +
                                     "#{(options[:placeholder] || attribute)}")
    # Source: https://robots.thoughtbot.com/nesting-content-tag-in-rails-3
    @template.content_tag :div, class: 'form-group' do
      @template.concat( label(attribute, class: 'control-label') do
        @template.concat @object.class.human_attribute_name(attribute)
        if !is_view_mode && @object.try(:required_attribute?, attribute)
          @template.concat REQUIRED_ATTRIBUTE_MARK
        end
      end)
      @template.concat send(input_type, attribute, class:       input_class,
                                                   placeholder: placeholder,
                                                   readonly:    readonly,
                                                   disabled:    is_view_mode)
    end
  end

  # Returns HTML for a cancel form button using Bootstrap classes.
  def cancel_button(destination_path = '/')
    @template.link_to I18n.t('form.cancel'), destination_path,
                                             class: "btn btn-default"
  end

  # Returns HTML for a edit form button using Bootstrap classes.
  def edit_button(destination_path = '/')
    # Consider using:
    # ActionDispatch::Routing::PolymorphicRoutes::edit_polymorphic_path(@object)
    @template.link_to I18n.t('form.edit'), destination_path,
                                             class: "btn btn-primary"
  end

  # Returns HTML for a submit form button using Bootstrap classes.
  def submit_button(button_text = nil, options = {})
    readonly      = options.include?(:readonly) ? options[:readonly] : false
    submit button_text || I18n.t('form.submit'), class: "btn btn-primary",
                                                 readonly: readonly
  end
end
