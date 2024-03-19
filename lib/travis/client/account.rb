# frozen_string_literal: true

require 'travis/client'

module Travis
  module Client
    class Account < Entity
      attributes :name, :login, :type, :repos_count, :subscribed, :education

      one :account
      many :accounts

      inspect_info :login
      id_field :login

      def self.cast_id(id)
        String(id)
      end

      def self.id?(object)
        object.is_a? String
      end

      def subscribed
        load_attribute('subscribed') { true } if member?
      end

      def education
        load_attribute('education') { false } if member?
      end

      def on_trial?
        !subscribed? and !education?
      end

      def repos_count
        load_attribute('repos_count') { repositories.count }
      end

      def repositories
        attributes['repositories'] ||= session.repos(owner_name: login)
      end

      def member?
        session.accounts.include? self
      end

      alias educational? education?

      private

      def load_attribute(name, &block)
        session.accounts if missing? name
        block ? attributes.fetch(name.to_s, &block) : attributes[name.to_s]
      end
    end
  end
end
