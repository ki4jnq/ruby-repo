module Entities
  class User
    include Virtus.model
    #include ActiveModel::Model

    attr_reader :posts

    attribute :id, Integer
    attribute :name, String
    attribute :email, String
    attribute :password, String

    def posts
      @posts ||= []
    end

    def ==(other)
      other.class == self.class && other.id == self.id
    end
  end
end
