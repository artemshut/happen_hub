FactoryBot.define do
  factory :group do
    sequence(:name) { |n| "Group #{n}" }
    description { "Test group" }
    association :creator, factory: :user

    after(:create) do |group|
      group.members << group.creator unless group.members.include?(group.creator)
    end
  end
end
