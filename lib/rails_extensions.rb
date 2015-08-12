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

  INPUT_FIELD_TYPES = {
    string:   :text_field,
    text:     :text_area,
    boolean:  :check_box
  }

  REQUIRED_ATTRIBUTE_MARK = '*'

  def input_type_for(attribute)
    INPUT_FIELD_TYPES[object.column_for_attribute(attribute).type] ||
      :text_field
  end

  # Returns HTML for a form field with labels and proper configuration
  # using Bootstrap classes.
  # Consider: https://github.com/bootstrap-ruby/rails-bootstrap-forms ;)
  def field_for(attribute, options = {})
    input_type  = input_type_for(options[:real_attribute] || attribute)
    input_class = 'form-control' unless input_type == :check_box
    readonly    = options.include?(:readonly) ? options[:readonly] : false
    placeholder = I18n.t "activerecord.placeholders." +
                         "#{object.class.name.downcase}." +
                         "#{(options[:placeholder] || attribute)}"
    # Source: https://robots.thoughtbot.com/nesting-content-tag-in-rails-3
    @template.content_tag :div, class: 'form-group' do
      @template.concat( label(attribute, class: 'control-label') do
        @template.concat @object.class.human_attribute_name(attribute)
        if @object.try :required_attribute?, attribute
          @template.concat REQUIRED_ATTRIBUTE_MARK
        end
      end)
      @template.concat send(input_type, attribute, class: input_class,
                                                   placeholder: placeholder,
                                                   readonly: readonly)
    end
  end

  # Returns HTML for a cancel form button using Bootstrap classes.
  def cancel_button(destination_path = '/')
    @template.link_to I18n.t('form.cancel'), destination_path, class: "btn btn-default"
  end

  # Returns HTML for a submit form button using Bootstrap classes.
  def submit_button(button_text = nil)
    submit button_text || I18n.t('form.submit'), class: "btn btn-primary"
  end
end
