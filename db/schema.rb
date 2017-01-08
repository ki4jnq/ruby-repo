Sequel.migration do
  change do
    create_table(:ar_internal_metadata) do
      column :key, "varchar", :null=>false
      column :value, "varchar"
      column :created_at, "datetime", :null=>false
      column :updated_at, "datetime", :null=>false
      
      primary_key [:key]
    end
    
    create_table(:schema_migrations) do
      column :version, "varchar", :null=>false
      
      primary_key [:version]
    end
  end
end
