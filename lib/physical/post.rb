module Physical
  class Post
    include Schema

    define_table :posts do
      integer :id, primary_key: true
      integer :user_id, foreign_key: [:users, :id]
      string :title
      text :body
    end
  end
end
