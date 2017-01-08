module Physical
  class User
    include Schema

    define_table :users do
      integer :id, primary_key: true
      string :name
      string :email
      string :password
    end

    has_many :posts
  end
end
