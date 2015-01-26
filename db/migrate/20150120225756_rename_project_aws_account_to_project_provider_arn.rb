class RenameProjectAwsAccountToProjectProviderArn < ActiveRecord::Migration
  def change
    rename_column :projects, :aws_account, :provider_arn
  end
end
