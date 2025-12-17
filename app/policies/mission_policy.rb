class MissionPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  alias_method :show?, :index?
  alias_method :create?, :admin?
  alias_method :update?, :admin?
  alias_method :destroy?, :admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      user ? scope.active : scope.none
    end
  end
end
