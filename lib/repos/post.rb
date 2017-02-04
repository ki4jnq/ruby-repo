module Repos
  class Post < Base
    persisted_attributes :id, :title, :body

    def find(id)
      query do
        where posts: { id: id }
      end
    end

    def all_for(user:)
      query do
        where posts: { user_id: user.id }
      end
    end
  end
end
