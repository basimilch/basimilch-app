# Adds the ability to be canceled to an ActiveRecord.
# SOURCE: https://www.tigraine.at/2012/02/03
#                                   /removing-delete-and-destroy-in-rails-models
module Cancelable

  # DOC: http://api.rubyonrails.org/v5.0.4/classes/ActiveSupport
  #                                       /Concern.html#method-i-append_features
  extend ActiveSupport::Concern

  # SOURCE: http://stackoverflow.com/a/1328093
  def self.included_in?(klass)
    klass.class == Class or raise "Parameter must be a class."
    klass.included_modules.include? self
  end

  class_methods do
    def before_cancel(method_name = nil, &block)
      set_callback :cancel, :before, block_given? ? block : method_name
    end

    def after_cancel(method_name = nil, &block)
      set_callback :cancel, :after, block_given? ? block : method_name
    end
  end

  included do

    # DOC: https://github.com/chaps-io/public_activity/tree/v1.4.1
    include PublicActivity::Common

    include PublicActivityHelper

    unless {canceled_at:      :datetime,
            canceled_by_id:   :integer,
            canceled_reason:  :string}.all? do |col, typ|
              columns_hash[col.to_s].try(:type) == typ
            end
      # DOC: http://ruby-doc.org/core-2.2.1/doc/syntax/literals_rdoc.html#label-Here+Documents
      raise MissingMigrationException, <<-ERROR_MSG.red
Model #{self} is missing the columns required by Cancelable.

# Add following migration:

cat << EOF > #{File.expand_path('../../..', __FILE__)}/db/migrate/#{Time.now.strftime("%Y%m%d%H%M%S")}_add_cancelable_columns_to_#{table_name}.rb
class AddCancelableColumnsTo#{table_name.titleize} < ActiveRecord::Migration
  def change
    add_column      :#{table_name}, :canceled_at,     :datetime
    add_column      :#{table_name}, :canceled_reason, :string
    add_reference   :#{table_name}, :canceled_by, references: :users, index: true
    add_foreign_key :#{table_name}, :users, column: :canceled_by_id
  end
end
EOF

# and then migrate the DB:

bundle exec rake db:migrate

ERROR_MSG
    end

    # NOTE: Differences between a Block, a Proc, and a Lambda:
    #       http://awaxman11.github.io/blog/2013/08/05
    #                                   /what-is-the-difference-between-a-block/

    # DOC: http://api.rubyonrails.org/v5.0.4/classes/ActiveSupport/Callbacks
    #                               /ClassMethods.html#method-i-define_callbacks
    define_callbacks :cancel, skip_after_callbacks_if_terminated: true

    attr_accessor :canceled_reason_key

    # Do not cancel if the model is already canceled.
    before_cancel do
      if changes[:canceled_at].first.present?
        logger.warn "#{self} was already canceled. Nothing to do."
        throw :abort # Throwing :abort in a 'before' callback stops
                     # the cancellation and further callbacks.
      end
    end

    # DOC: http://api.rubyonrails.org/v5.0.4/classes/ActiveRecord/Callbacks.html

    # Do not allow 'destroy' if the model is not canceled to ensure that the
    # action is done on purpose. Moreover this ensures that the cancellation
    # has an 'author'. If we automatically cancel the item in a 'before_destroy'
    # callback e.g., the 'cancel' action could not capture the author (or the
    # code to allow it would be too complex).
    before_destroy do
      canceled? or (
        logger.warn "#{self} must be canceled before destroying it."
        # SOURCE: http://guides.rubyonrails.org/v5.0.4/upgrading_ruby_on_rails.html#halting-callback-chains-via-throw-abort
        throw :abort # Throwing :abort in a 'before' callback stops the action
      )
    end

    # Do not allow 'update' if the model is canceled.
    before_save do
      canceling? or
      !canceled? or (
        logger.warn "#{self} is canceled and cannot be updated."
        # SOURCE: http://guides.rubyonrails.org/v5.0.4/upgrading_ruby_on_rails.html#halting-callback-chains-via-throw-abort
        throw :abort # Throwing :abort in a 'before' callback stops the action
      )
    end

    # Record canceled activity.
    # TODO: Ensure that this is the first after_cancel executed. In fact, why
    #       not place it right in the :cancel method?
    after_cancel do
      record_activity :cancel, self, owner: canceled_by
    end

    scope :not_canceled,  -> { canceled(false) }
    scope :canceled,  ->(canceled = true) do
      canceled ? where.not(canceled_at: nil) : where(canceled_at: nil)
    end
    scope :include_canceled,  ->(include_canceled = true) do
      include_canceled ? all : not_canceled
    end
  end

  # Returns true if the model is being saved as canceled.
  def canceling?
    if c = changes[:canceled_at]
      c.first.blank? && c.second.present?
    else
      false
    end
  end

  def cancel(reason: nil, reason_key: nil, author: nil)
    author.present? or raise "Cancellation must have an author!"
    self.canceled_at          = Time.current
    self.canceled_reason      = reason || reason_key
    self.canceled_reason_key  = reason_key
    self.canceled_by_id       = case author
                                when Integer
                                  author
                                when User
                                  author.id
                                end
    run_callbacks :cancel do
      save validate: false
    end ensure reload # Reload the original object if some Exception occurred.
  end

  def canceled?
    canceled_at.present?
  end

  def not_canceled?
    !canceled?
  end

  def canceled_by
    User.find_by(id: canceled_by_id)
  end
end

class MissingMigrationException < Exception
end
