class EventChecklistItemSerializer
  include JSONAPI::Serializer

  attributes :title,
             :due_at,
             :completed,
             :completed_at,
             :position,
             :assignee_id,
             :event_checklist_id,
             :event_id,
             :created_at,
             :updated_at

  attribute :assignee_name do |item|
    item.assignee&.full_name
  end
end
