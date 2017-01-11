module Entities
  class Post
    include Virtus.model

    attribute :id, Integer
    attribute :user_id, Integer
    attribute :title, String
    attribute :body, String

    attribute :user, Entities::User
  end
end
