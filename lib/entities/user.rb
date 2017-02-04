module Entities
  class User
    include Virtus.model

    attribute :id, Integer
    attribute :name, String
    attribute :email, String
    attribute :password, String

    attribute :posts, Array[Entities::Post]
  end
end
