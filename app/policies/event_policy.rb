class EventPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    public_event? || manage? || participant? || friend_can_view?
  end

  def create?
    user.present?
  end

  def update?
    manage?
  end

  def destroy?
    manage?
  end

  def edit?
    update?
  end

  def invite_group?
    manage?
  end

  def add_friend?
    manage?
  end

  def remove_file?
    manage?
  end

  def availability_preview?
    manage?
  end

  def update_rsvp?
    user.present? && (manage? || participant? || friend_can_view?)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if admin?
      return scope.none unless user

      scope.merge(Event.visible_to(user))
    end
  end

  private

  def manage?
    admin? || owns_event? || organizer_for_record? || (participant? && record.visibility_friends?)
  end

  def owns_event?
    return false unless user && record.respond_to?(:user_id)

    record.user_id == user.id
  end

  def organizer_for_record?
    return false unless user
    return false unless record.respond_to?(:id)

    user.has_role?(:organizer) || user.has_role?(:organizer, resource: record)
  end

  def participant?
    return false unless user && record.respond_to?(:event_participations)

    record.event_participations.exists?(user_id: user.id)
  end

  def friend_can_view?
    return false unless user && record.respond_to?(:visibility_friends?)

    record.visibility_friends? && record.user&.friends_with?(user)
  end

  def public_event?
    record.respond_to?(:visibility_public?) && record.visibility_public?
  end
end
