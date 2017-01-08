module Repos
  class User < Base
    def find(id)
      query do
        # select :users
        where users: { id: id }
      end
    end

    def find_with_posts(id)
      query do
        select :users, :posts
        where users: { id: id }
        join :posts, user_id: :id
      end
    end

    def persist(user)
      if user.id
        conn.where(id: user.id).update(user.attributes)
      else
        conn.insert user.attributes
      end
    end
  end
end
