module ApplicationHelper

  APP_NAME = "meine.basimil.ch"

  # Returns the full title of the page
  def full_title(page_title = '')
    if page_title.empty?
      APP_NAME
    else
      page_title + ' | ' + APP_NAME
    end
  end

  # Returns HTML for release messages with links to the commits to be displayed
  # in the version footer partial.
  def release_commit_messages
    last_commit_url = Rails.configuration.x.release[:commit_url]
    commit_msgs     = Rails.configuration.x.release[:commit_msgs].split(/\n/)
    parent_commit_indicator = "%5E" # URL-encoded '^' char
    commit_msgs_html = "<div class='gh-commit-msgs'>"
    commit_msgs.each_with_index do |commit_msg, index|
      commit_msgs_html += "<a target='_blank' href='#{last_commit_url}" +
      "#{parent_commit_indicator * index}'>#{commit_msg}</a><br>"
    end
    commit_msgs_html += "</div>"
  end

  # Helper to prevent forgetting the console in production and to type less. ;)
  # DOC: http://ruby-doc.org/core-2.2.0/Binding.html#method-i-receiver
  # DOC: http://ruby-doc.org/core-2.1.1/Kernel.html#method-i-caller
  def c
    msg = "Console used in #{caller[0]} by #{binding.receiver}".red
    raise msg if Rails.env.test?
    logger.warn msg
    console if Rails.env.development?
  end

  # Source: http://stackoverflow.com/a/4983354
  def raise_404
    raise ActionController::RoutingError.new('Not Found')
  end

  # Friendly forwarding
  # Source: https://www.railstutorial.org/book/_single-page
  #                                                     #sec-friendly_forwarding

  # Redirects to stored location (or to the default).
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # Stores the URL trying to be accessed.
  def store_location
    session[:forwarding_url] = request.url if request.get?
  end

  # Adds a label to be displayed below the page title.
  def title_label(arg, options = {type: :default})
    (@title_labels ||= []) << options.merge(text: Symbol === arg ?
                                            I18n.t("title_labels.#{arg}") : arg.to_s)
  end


  def div_for_action(class_suffix: "content")
    content_tag :div,
                class: "#{controller_name}-#{action_name}-#{class_suffix}" do
      yield
    end
  end

  # Returns a string with two 3-digit numbers separated by a space.
  def rand_validation_code
    "#{rand.to_s[2..4]} #{rand.to_s[2..4]}"
  end

  # Returns the localized string with the same behaviour than the default 't'
  # helper in the views, i.e. prefixing the key by the current controller and
  # view names.
  def tc(k)
    I18n.t("#{controller_name}.#{action_name}.#{k}")
  end

  # Adds a localised flash message with the given key and value. If the value is
  # a string, it's directly used. If it's a symbol, it's considered a key for a
  # localized string, see 't(k)' above.
  # E.g. instead of using
  #   flash[:success] = t('.email_successfully_sent')
  # you can use
  #   flash_t :success, :email_successfully_sent
  def flash_t(k, v, global: false)
    flash[k] = case
    when global
      I18n.t("flash.#{v}")
    when (Symbol === v)
      tc(v)
    else
      v
    end
  end
  def flash_now_t(k, v, global: false)
    flash.now[k] = case
    when global
      I18n.t("flash.#{v}")
    when (Symbol === v)
      tc(v)
    else
      v
    end
  end

  def icon(icon_name, label = nil)
    content_tag :span, class: "icon-container" do
      concat(content_tag :span, nil, {
          class: "glyphicon glyphicon-#{icon_name.to_s.dasherize}",
          "aria-hidden" => true
        })
      concat(label.to_s) if label
      yield if block_given?
    end
  end
end
