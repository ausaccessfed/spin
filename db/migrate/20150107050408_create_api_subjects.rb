class CreateAPISubjects < ActiveRecord::Migration
  def change
    create_table :api_subjects do |t|
      t.string :x509_cn,                  null: false
      t.string :description, default: '', null: false
      t.string :contact_name,             null: false
      t.string :contact_mail,             null: false
      t.boolean :enabled, default: true,  null: false

      t.timestamps
    end
  end
end
