# Migration responsible for creating a table with activities
class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.belongs_to :trackable, :polymorphic => true
      t.belongs_to :owner, :polymorphic => true
      t.string  :key
      t.text    :parameters
      t.belongs_to :recipient, :polymorphic => true
      # Custom field 'scope'
      # DOC: https://github.com/chaps-io/public_activity/wiki/%5BHow-to%5D-Use-custom-fields-on-Activity#migration
      # SEE: PublicActivityHelper#activity_flags
      t.string  :scope
      t.string  :visibility
      t.string  :severity

      t.timestamps
    end

    add_index :activities, [:trackable_id, :trackable_type]
    add_index :activities, [:owner_id, :owner_type]
    add_index :activities, [:recipient_id, :recipient_type]
    add_index :activities, [:created_at, :key]
  end
end
