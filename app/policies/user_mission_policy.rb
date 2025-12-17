class UserMissionPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def update?
    owns_record?
  end

  private

  def owns_record?
    record.user_id == user&.id || admin?
  end
end
