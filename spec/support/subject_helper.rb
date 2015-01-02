RSpec.shared_examples 'a mocked subject' do
  let(:Subject) { double }
  let(:subject_for_session) { double }

  before do
    allow(Subject)
      .to receive(:find)
      .and_return(subject_for_session)
  end
end

RSpec.shared_examples 'with no projects' do
  before do
    allow(subject_for_session)
      .to receive(:active_project_count)
      .and_return(0)
  end
end

RSpec.shared_examples 'with 1 project' do
  let(:projects) { Array.new(1) { create(:project_role) } }

  before do
    allow(subject_for_session)
      .to receive(:active_project_count)
      .and_return(1)

    allow(subject_for_session)
      .to receive(:distinct_project_roles)
      .and_return(projects)
  end
end

RSpec.shared_examples 'with 3 projects' do
  let(:projects) { Array.new(3) { create(:project_role) } }

  before do
    allow(subject_for_session)
      .to receive(:active_project_count)
      .and_return(3)

    allow(subject_for_session)
      .to receive(:distinct_project_roles)
      .and_return(projects)
  end
end
