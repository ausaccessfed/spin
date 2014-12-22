RSpec.shared_examples 'a mocked subject' do
  let(:Subject) { double }
  let(:subject_for_session) { double }
  let(:project_roles) { double }
  let(:select_projects_association) { double }

  before do
    allow(Subject)
      .to receive(:find)
      .and_return(subject_for_session)
  end

  before do
    allow(subject_for_session)
      .to receive(:project_roles)
      .and_return(project_roles)
  end

  before do
    allow(project_roles)
      .to receive(:select)
      .and_return(select_projects_association)
  end
end

RSpec.shared_examples 'with no projects' do
  before do
    allow(select_projects_association)
      .to receive(:distinct)
      .and_return({})
  end
end

RSpec.shared_examples 'with 1 project' do
  let(:projects) { [create(:project_role)] }

  before do
    allow(select_projects_association)
      .to receive(:distinct)
      .and_return(projects)
  end
end

RSpec.shared_examples 'with 3 projects' do
  let(:projects) { Array.new(3) { create(:project_role) } }

  before do
    allow(select_projects_association)
      .to receive(:distinct)
      .and_return(projects)
  end
end
