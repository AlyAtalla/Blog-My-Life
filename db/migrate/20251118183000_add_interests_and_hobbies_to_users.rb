class AddInterestsAndHobbiesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :interests, :text
    add_column :users, :hobbies, :text
  end
end
