module Repos
  class Post < Base
    def find(id)
      to_singular conn.filter(id: id).first
    end

    def all
      to_array conn.all
    end

    def all_for(user:)
      to_array conn.filter(user_id: user.id)
    end

    def persist(post)
      if post.id
        conn.where(id: post.id).update(post.attributes)
      else
        conn.insert post.attributes
      end
    end
  end
end