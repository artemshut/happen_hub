class CommentPolicy < ApplicationPolicy
  def show?
    event_visible?
  end

  def create?
    user.present? && event_visible?
  end

  def destroy?
    return false unless user

    user.id == record.user_id || record.event.user_id == user.id || user.has_role?(:admin)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user
        scope.joins(:event).merge(Event.visible_to(user))
      else
        scope.joins(:event).merge(Event.where(visibility: :public))
      end
    end
  end

  private

  def event_visible?
    EventPolicy.new(user, record.event).show?
  end
end
