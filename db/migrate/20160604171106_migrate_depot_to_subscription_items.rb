class MigrateDepotToSubscriptionItems < ActiveRecord::Migration

  # DOC: http://guides.rubyonrails.org/v5.2.0/active_record_migrations.html
  # DOC: http://api.rubyonrails.org/v5.2.0/classes/ActiveRecord/Migration.html

  def up
    add_reference :subscription_items, :depot, index: true, foreign_key: true

    SubscriptionItem.reset_column_information

    say_with_time "migrating depot from subscription to subscription_item" do
      SubscriptionItem.all.each do |item|
        item.update_column :depot_id, item.subscription.depot_id
      end
    end

    remove_reference :subscriptions, :depot, index: true, foreign_key: true
  end

  def down

    say "Note that the depot change history of each subscription will".yellow
    say "now be forgotten and only the last used depot will be persisted".yellow
    say "in the subscription object itself.".yellow

    add_reference :subscriptions, :depot, index: true, foreign_key: true

    Subscription.reset_column_information

    say_with_time "migrating depot from subscription_item to subscription" do
      Subscription.all.each do |subscription|
        subscription.update_column(
          :depot_id,
          subscription.subscription_items.last&.depot_id
        )
      end
    end

    remove_reference :subscription_items, :depot, index: true, foreign_key: true
  end

end
