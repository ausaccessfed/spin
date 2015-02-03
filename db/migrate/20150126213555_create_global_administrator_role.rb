class CreateGlobalAdministratorRole < ActiveRecord::Migration
  class Role < ActiveRecord::Base
    has_many :permissions
  end

  class Permission < ActiveRecord::Base
  end

  def change
    role = Role.find_or_create_by!(name: 'Global Administrator')
    role.permissions.find_or_create_by!(value: '*')
  end
end
