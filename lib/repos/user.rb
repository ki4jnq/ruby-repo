module Repos
  class User < Base
    def initialize
    end

    def find(id)
      to_singular conn.filter(id: id).first
    end

    def all
      to_array conn.all
    end

    def find_with_posts(id)
      conn.select {
          Physical::User.scoped_attrs | Physical::Post.scoped_attrs
        }
        .where(users__id: id)
        .left_join(:posts, user_id: :id)
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
