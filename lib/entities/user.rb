module Entities
  class User
    include Virtus.model
    #include ActiveModel::Model

    attribute :id, Integer
    attribute :name, String
    attribute :email, String
    attribute :password, String

    attribute :posts, Array[Entities::Post]

    def ==(other)
      other.class == self.class && other.id == self.id
    end
  end
end
