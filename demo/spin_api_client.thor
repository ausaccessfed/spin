require 'rest_client'
require 'json'

class SpinApiClient < Thor
  BASE_URL = 'http://localhost:8080/api'

  desc 'get_subjects', 'GET /subjects'
  def get_subjects
    run('get', subjects_path)
  end

  desc 'delete_subject', 'DELETE /subjects/<subject_id>'
  method_option :subject_id, :required => true
  def delete_subject
    run('delete', subject_path)
  end

  desc 'get_organisations', 'GET /organisations'
  def get_organisations
    run('get', organisations_path)
  end

  desc 'create_organisation', 'POST /organisations'
  method_option :name, :required => true
  method_option :external_id, :required => true
  def create_organisation
    run('post', organisations_path, build_organisation_json)
  end

  desc 'delete_organisation', 'DELETE /organisations/<organisation_id>'
  method_option :organisation_id, :required => true
  def delete_organisation
    run('delete', organisation_path)
  end

  method_option :organisation_id, :required => true
  desc 'get_projects', 'GET /organisations/<organisation_id>/projects'
  def get_projects
    run('get', organisation_projects_path)
  end

  method_option :organisation_id, :required => true
  method_option :name, :required => true
  method_option :provider_arn, :required => true
  desc 'create_project', 'POST /organisations/<organisation_id>/projects'
  def create_project
    run('post', organisation_projects_path, build_project_json)
  end

  method_option :organisation_id, :required => true
  method_option :project_id, :required => true
  desc 'delete_project', 'DELETE /organisations/<organisation_id>/projects/<project_id>'
  def delete_project
    run('delete', organisation_project_path)
  end

  method_option :organisation_id, :required => true
  method_option :project_id, :required => true
  desc 'get_roles', 'GET /organisations/<organisation_id>/projects/<project_id>/roles'
  def get_roles
    run('get', organisation_project_roles_path)
  end

  method_option :organisation_id, :required => true
  method_option :project_id, :required => true
  method_option :name, :required => true
  method_option :role_arn, :required => true
  desc 'create_role', 'POST /organisations/<organisation_id>/projects/<project_id>/roles/'
  def create_role
    run('post', organisation_project_roles_path, build_project_role_json)
  end


  method_option :organisation_id, :required => true
  method_option :project_id, :required => true
  method_option :role_id, :required => true
  desc 'delete_role', 'DELETE /organisations/<organisation_id>/projects/<project_id>/roles/<role_id>'
  def delete_role
    run('delete', organisation_project_role_path)
  end

  method_option :organisation_id, :required => true
  method_option :project_id, :required => true
  method_option :role_id, :required => true
  method_option :subject_id, :required => true
  desc 'grant_project_role_to_subject', 'POST /organisations/<organisation_id>/projects/<project_id>/roles/<role_id>/members'
  def grant_project_role_to_subject
    run('post', organisation_project_role_members_path, build_grant_subject_json)
  end

  method_option :organisation_id, :required => true
  method_option :project_id, :required => true
  method_option :role_id, :required => true
  method_option :subject_id, :required => true
  desc 'revoke_project_role_from_subject', 'DELETE /organisations/<organisation_id>/projects/<project_id>/roles/<role_id>/members/<subject_id>'
  def revoke_project_role_from_subject
    run('delete', "#{organisation_project_role_members_path}/#{options[:subject_id]}")
  end


  private

  def run(method, request_path, body = nil, base_url = BASE_URL)
    puts_request(base_url, method, request_path, body)

    begin
      response = send_request(base_url, method, request_path, body)
      puts_response(response)
    rescue => e
      puts_error(e)
    end
  end

  def puts_request(base_url, method, request_path, body)
    puts("#{method.upcase} #{base_url}#{request_path}")
    puts(json_to_formatted_string(body)) if body
  end

  def send_request(base_url, method, request_path, body)
    if (body)
      RestClient.send(method, "#{base_url}#{request_path}", body,
                      :content_type => :json, :accept => :json)
    else
      RestClient.send(method, "#{base_url}#{request_path}")
    end
  end

  def puts_error(e)
    puts("\n-->")
    puts(e.inspect)
  end

  def puts_response(response)
    puts("\n-->")
    puts(response.code)
    response_body = response.to_str
    if (response_body != ' ')
      puts(json_to_formatted_string(response_body))
    end
  end

  def json_to_formatted_string(response)
    JSON.pretty_generate(string_to_json(response))
  end

  def string_to_json(response)
    JSON.parse(response)
  end


  def build_organisation_json
    "{ \"organisation\":{ \"name\":\"#{options[:name]}\", \"external_id\":\"#{options[:external_id]}\" }}"
  end

  def build_project_json
    "{ \"project\":{ \"name\":\"#{options[:name]}\", \"provider_arn\":\"#{options[:provider_arn]}\", \"active\":\"true\" } }"
  end

  def build_project_role_json
    "{ \"project_role\":{ \"name\":\"#{options[:name]}\", \"role_arn\":\"#{options[:role_arn]}\" } }"
  end

  def build_grant_subject_json
    "{ \"subject_project_roles\":{ \"subject_id\":\"#{options[:subject_id]}\"} }"
  end

  def subjects_path
    '/subjects'
  end

  def subject_path
    "/subjects/#{options[:subject_id]}"
  end

  def organisations_path
    '/organisations'
  end

  def organisation_projects_path
    "#{organisation_path}/projects"
  end

  def organisation_path
    "#{organisations_path}/#{options[:organisation_id]}"
  end

  def organisation_project_path
    "#{organisation_projects_path}/#{options[:project_id]}"
  end

  def organisation_project_roles_path
    "#{organisation_project_path}/roles"
  end

  def organisation_project_role_path
    "#{organisation_project_roles_path}/#{options[:role_id]}"
  end

  def organisation_project_role_members_path
    "#{organisation_project_role_path}/members"
  end

end
