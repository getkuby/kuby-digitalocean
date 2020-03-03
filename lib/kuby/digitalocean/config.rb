require 'kube-dsl'

module Kuby
  module DigitalOcean
    class Config
      extend ::KubeDSL::ValueFields

      value_fields :access_token, :cluster_id
    end
  end
end
