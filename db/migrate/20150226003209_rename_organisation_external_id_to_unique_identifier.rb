class RenameOrganisationExternalIdToUniqueIdentifier < ActiveRecord::Migration
  def change
    rename_column :organisations, :external_id, :unique_identifier
  end
end
