FactoryGirl.define do
  factory :subject do
    name { Faker::Name.name }
    mail { Faker::Internet.email(name) }
    shared_token { SecureRandom.urlsafe_base64(16) }
    targeted_id do
      "https://rapid.example.com!https://ide.example.com!#{SecureRandom.hex}"
    end

    trait :assigned_to_project do
      after(:create) do |subject|
        project_role = create(:project_role)
        create(:subject_project_role, project_role: project_role,
                                      subject: subject)
      end
    end

    # Trait for multiple project roles across multiple projects
    #
    # Subject -> project_1 -> {role_1, role_2}
    #         -> project_2 -> {role_1}
    #
    trait :assigned_to_many_projects do
      after(:create) do |subject|
        project_1 = create(:project)
        project_1_role_1 = create(:project_role, project: project_1)
        project_1_role_2 = create(:project_role, project: project_1)
        create(:subject_project_role, project_role: project_1_role_1,
                                      subject: subject)
        create(:subject_project_role, project_role: project_1_role_2,
                                      subject: subject)
        project_2 = create(:project)
        project_2_role_1 = create(:project_role, project: project_2)
        create(:subject_project_role, project_role: project_2_role_1,
                                      subject: subject)
      end
    end

    trait :authorized do
      transient { permission '*' }

      after(:create) do |subject, attrs|
        perm = create(:permission, value: attrs.permission)
        create(:subject_role, role: perm.role, subject: subject)
      end
    end
  end
end
