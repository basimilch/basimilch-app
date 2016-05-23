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

  # Adds a localized flash message with the given key and value. If the value is
  # a string, it's directly used. If it's a symbol, it's considered a key for a
  # localized string, see 't(k)' above.
  # E.g. instead of using
  #   flash[:success] = t('.email_successfully_sent')
  # you can use
  #   flash_t :success, :email_successfully_sent
  def flash_t(k, v, global: false)
    log_flash k, v
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
    log_flash k, v
    flash.now[k] = case
    when global
      I18n.t("flash.#{v}")
    when (Symbol === v)
      tc(v)
    else
      v
    end
  end

  # Returns a div element with the image centered and horizontally fitting the
  # with of the div.
  def fit_image_tag(image_url, width: nil, height: nil, css_class: nil)
    html_options = {
      class: 'fit-image',
      style: "background-image: url('#{image_url}');"
      }
    html_options[:class] << " #{css_class};" if css_class.present?
    html_options[:style] << "height:#{height};" if height.present?
    html_options[:style] << "width:#{width};"   if width.present?
    content_tag :div, nil, html_options
  end

  # Some notes about :to_i vs :to_int vs Integer()
  # DOC: http://ruby-doc.org/core-2.2.4/Kernel.html#method-i-Integer
  # SOURCE: http://stackoverflow.com/a/10093533/
  # SOURCE: http://stackoverflow.com/a/11182123/

  # Returns the localized weekday name for the given index. 0 means Sunday.
  def localized_weekday_name(d)
    d = Integer(d)
    (0..6).include? d or raise ArgumentError, "#{d.inspect} is not valid"
    t("date.day_names")[d]
  end

  # Returns the localized month name for the given index. 1 means January.
  def localized_month_name(m)
    m = Integer(m)
    (1..12).include? m or raise ArgumentError, "#{m.inspect} is not valid"
    t("date.month_names")[m]
  end

  # DOC: https://bootstrapdocs.com/v3.3.6/docs/components/#glyphicons
  def icon(icon_name, label = nil)
    content_tag :span, class: "icon-container" do
      concat(content_tag :span, nil, {
          class: "glyphicon glyphicon-#{icon_name.to_s.dasherize}",
          "aria-hidden" => true
        })
      concat(label.to_s) if label
      concat(yield) if block_given?
    end
  end

  # Returns a phone number element, displayed as 'code' for readability,
  # prefixed with a 'phone' icon and with an underlying 'tel:' link.
  def icon_tel_to(tel, display_tel = tel, published: true)
    content_tag :code, icon_to_html_options(:tel, published) do
      link_to "tel:#{tel}" do
        icon :earphone, display_tel
      end
    end
  end

  # Returns a 'mail_to' link element, displayed as 'code' for readability and
  # prefixed with an 'envelope' icon.
  def icon_mail_to(address, published: true)
    content_tag :code, icon_to_html_options(:mail, published) do
      mail_to address do
        icon :envelope, address
      end
    end
  end

  def menu_action(label, path, icon: nil, link_method: nil, link_confirm: nil)
    content_tag :li do
      html_options = {}
      html_options[:method] = link_method if link_method
      html_options[:data]   = { confirm: link_confirm } if link_confirm
      html_options[:class]  = 'menu-action-with-glyphicon' if icon
      link_to path, html_options do
        if icon
          concat content_tag :span, nil, class: "glyphicon glyphicon-#{icon}"
        end
        concat label
      end
    end
  end

  def menu_action_separator
    content_tag :li, nil, role: 'separator', class: 'divider'
  end

  def localized_time_tag(time, format = :long)
    return if time.blank?
    label = format == :relative ?   time.relative_in_words.strip :
                                    time.to_localized_s(format).strip
    tooltip = format == :long ? nil : time.to_localized_s(:long).strip
    time_tag time, label, title: tooltip
  end

  def localized_date_tag(date, format = :long)
    return if date.blank?
    localized_time_tag date.to_date, format
  end

  def t_abbr(t_key)
    content_tag :span, title: t(t_key), data: {toggle: "tooltip"} do
      t t_key + "_abbr"
    end
  end

  def display_next_update_flash_if_needed
    if logged_in? && Subscription.open_update_window?
      delivery_date = Date.commercial Date.current.year,
                                      Subscription::NEXT_UPDATE_WEEK_NUMBER,
                                      # TODO: Remove the hardcoded day.
                                      6 # Saturday
      deadline_date = delivery_date - 1.day -
                              Subscription::UPDATE_DEADLINE_BEFORE_DELIVERY_DAY
      flash_now_t :info_subscription_updatable,
                  t('flash.subscription_can_be_updated_html',
                     delivery_date_tag: localized_date_tag(delivery_date),
                     deadline_date_tag: localized_date_tag(deadline_date))
    end
  end

  private

    def flash_k_to_logger_level(k)
      case k
      when /warning/ then :warn
      when /danger/  then :warn
      else :info
      end
    end

    def log_flash(k, v)
      flash_t_method = caller_method # NOTE: Cannot be inlined in the string
      caller_info = caller[1].sub(/.+\//,'')
      logger.send flash_k_to_logger_level(k),
            "#{flash_t_method} in #{caller_info}: #{k.inspect} => #{v.inspect}"
    end

    def icon_to_html_options(type, published = true)
      {'class'          => "icon-#{type}-to#{' not-published' if !published}",
       'data-toggle'    => 'tooltip',
       'data-placement' => 'top',
       'title'          => t(".info_#{published ? '' : 'not_'}published")}
    end
end
