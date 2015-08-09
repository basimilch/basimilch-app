module ApplicationHelper

  APP_NAME = "my.basimilch"

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
end
