class GroupPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    manage? || member?
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

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless user

      scope.visible_to(user)
    end
  end

  private

  def manage?
    user.present? &&
      record.respond_to?(:user_id) &&
      record.user_id == user.id
  end

  def member?
    user.present? &&
      record.respond_to?(:members) &&
      record.members.exists?(id: user.id)
  end
end
