class AddAuthorToPoems < ActiveRecord::Migration[7.1]
  def change
    add_reference :poems, :author, polymorphic: true, null: true
  end
end
