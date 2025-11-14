ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation, :tag, :first_name,
                :last_name, :birthday, :username, :provider, :uid, :fcm_token,
                :platform, :confirmed_at, :confirmation_token,
                :confirmation_sent_at, :unconfirmed_email, :remember_created_at,
                :plan_id

  includes :roles, :plan

  index do
    selectable_column
    id_column
    column :email
    column :username
    column :tag
    column :first_name
    column :last_name
    column(:plan) { |user| user.plan&.name }
    column :created_at
    actions
  end

  filter :email
  filter :username
  filter :tag
  filter :first_name
  filter :last_name
  filter :provider
  filter :platform
  filter :created_at
  filter :plan

  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :first_name
      f.input :last_name
      f.input :username
      f.input :tag
      # f.input :birthday, as: :datepicker
      f.input :provider
      f.input :uid
      f.input :fcm_token
      f.input :platform
      f.input :confirmed_at, as: :datetime_picker
      f.input :plan, collection: Plan.ordered_for_display.map { |plan| [ plan.name, plan.id ] }
    end
    f.actions
  end

  sidebar "Plan & Limits", only: :show do
    attributes_table_for resource do
      row(:plan) { resource.plan&.name }
      row("Active events") { resource.active_events_count }
      row("Plan limit") { helpers.plan_limit_label(resource.plan) }
    end

    if Plan.any?
      form_with url: update_plan_admin_user_path(resource), method: :patch do |form|
        concat form.label :plan_id, "Switch plan", class: "label"
        concat form.select :plan_id,
                           options_from_collection_for_select(Plan.ordered_for_display, :id, :name, resource.plan_id),
                           {}, class: "select"
        concat form.submit "Update plan", class: "button"
      end
    end
  end

  member_action :update_plan, method: :patch do
    plan = Plan.find(params[:plan_id])

    if plan.max_active_events.present? && resource.active_events_count > plan.max_active_events
      redirect_to resource_path, alert: "User has more active events than #{plan.name} allows."
      return
    end

    resource.update!(plan:)
    redirect_to resource_path, notice: "Plan updated to #{plan.name}."
  end
end
