require 'kube-dsl'
require 'digest'

module Kuby
  module DigitalOcean
    class Config
      extend ::KubeDSL::ValueFields

      value_fields :access_token, :cluster_id

      def hash_value
        Digest::SHA256.hexdigest(
          [access_token, cluster_id].join(':')
        )
      end
    end
  end
end
