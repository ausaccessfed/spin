RSpec.shared_examples 'a mocked subject' do
  let(:Subject) { double }
  let(:subject_for_session) { double }
  let(:roles) { [] }
  let(:project_roles) { [] }

  before do
    allow(Subject)
      .to receive_messages(find: subject_for_session,
                           find_by_id: subject_for_session)

    allow(subject_for_session)
      .to receive_messages(permits?: false,
                           roles: roles,
                           active_project_roles: project_roles,
                           functioning?: true,
                           name: Faker::Name.name,
                           targeted_id: Faker::Lorem.characters)
  end
end

RSpec.shared_examples 'with no projects' do
  let(:project_roles) { [] }
end

RSpec.shared_examples 'with 1 project' do
  let(:project_roles) { create_list(:project_role, 1) }
end

RSpec.shared_examples 'with 3 projects' do
  let(:project_roles) { create_list(:project_role, 3) }
end

RSpec.shared_examples 'with admin permissions' do
  let(:roles) { [create(:permission).role] }

  before do
    allow(subject_for_session)
      .to receive(:permits?)
      .and_return(true)
  end
end
