require 'kuby'
require 'kuby/digitalocean/provider'

module Kuby
  module DigitalOcean
    autoload :Config, 'kuby/digitalocean/config'
  end
end

Kuby.register_provider(:digitalocean, Kuby::DigitalOcean::Provider)
