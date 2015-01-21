RSpec.shared_examples 'a mocked subject' do
  let(:Subject) { double }
  let(:subject_for_session) { double }
  let(:roles) { [] }
  let(:project_roles) { [] }

  before do
    allow(subject_for_session)
      .to receive(:permits?)
      .and_return(false)

    allow(Subject)
      .to receive(:find)
      .and_return(subject_for_session)

    allow(subject_for_session)
      .to receive(:project_roles)
      .and_return(project_roles)

    allow(subject_for_session)
      .to receive(:roles)
      .and_return(roles)
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
