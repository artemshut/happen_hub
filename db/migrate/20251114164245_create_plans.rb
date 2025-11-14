class CreatePlans < ActiveRecord::Migration[8.0]
  class Plan < ApplicationRecord
    self.table_name = "plans"
  end

  class User < ApplicationRecord
    self.table_name = "users"
  end

  def up
    create_table :plans do |t|
      t.string :name, null: false
      t.string :key, null: false
      t.string :tagline
      t.integer :monthly_price_cents, null: false, default: 0
      t.integer :annual_price_cents, null: false, default: 0
      t.integer :max_active_events
      t.boolean :highlighted, null: false, default: false
      t.integer :priority, null: false, default: 0
      t.jsonb :features, null: false, default: []
      t.timestamps
    end

    add_index :plans, :key, unique: true

    add_reference :users, :plan, foreign_key: true

    seed_plans!
    backfill_user_plans!

    change_column_null :users, :plan_id, false
  end

  def down
    remove_reference :users, :plan, foreign_key: true
    drop_table :plans
  end

  private

  def seed_plans!
    Plan.reset_column_information

    plans = [
      {
        key: "basic",
        name: "Starter Circle",
        tagline: "Host a handful of intimate plans for free.",
        monthly_price_cents: 0,
        annual_price_cents: 0,
        max_active_events: 3,
        highlighted: false,
        priority: 1,
        features: [
          "Up to 3 active events at a time",
          "Smart invites & RSVPs",
          "Shared maps and files"
        ]
      },
      {
        key: "social_plus",
        name: "Social Spark",
        tagline: "Level up recurring hangs with extra capacity.",
        monthly_price_cents: 1200,
        annual_price_cents: 12000,
        max_active_events: 10,
        highlighted: true,
        priority: 2,
        features: [
          "Up to 10 active events",
          "Priority reminders & follow-ups",
          "Group polls & suggestion boosts",
          "Guest availability heatmap"
        ]
      },
      {
        key: "galaxy",
        name: "Galaxy Host",
        tagline: "All-access hosting for power planners.",
        monthly_price_cents: 2400,
        annual_price_cents: 24000,
        max_active_events: nil,
        highlighted: false,
        priority: 3,
        features: [
          "Unlimited active events",
          "VIP launch announcements",
          "White-glove onboarding for groups",
          "Advanced analytics & share insights"
        ]
      }
    ]

    plans.each do |attrs|
      Plan.find_or_initialize_by(key: attrs[:key]).tap do |plan|
        plan.assign_attributes(attrs)
        plan.save!
      end
    end
  end

  def backfill_user_plans!
    default_plan_id = Plan.find_by!(key: "basic").id

    User.reset_column_information
    User.where(plan_id: nil).update_all(plan_id: default_plan_id)
  end
end
