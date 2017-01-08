module Repos
  class User < Base
    def find(id)
      query do
        where users: { id: id }
      end.first
    end

    def find_new_users
      query do
        left_join :posts, user_id: :id
        where posts: { id: nil }
      end
    end

    def find_with_posts(id)
      query :users, :posts do
        join :posts, user_id: :id
        where users: { id: id }
      end
    end
  end
end
