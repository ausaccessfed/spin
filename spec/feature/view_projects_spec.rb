require 'rails_helper'

RSpec.feature 'Visiting the projects page', type: :feature do
  background do
    attrs = create(:aaf_attributes, displayname: 'test')

    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)
  end

  scenario 'after log in' do
    visit '/'
    expect(page).to have_content("Here's what we know about you: Nothing")
    # TODO: test flow of log in / projects once it's fleshed out
  end
end
