require 'colorized_string'
require 'droplet_kit'
require 'fileutils'

module Kuby
  module DigitalOcean
    class Provider
      KUBECONFIG_EXPIRATION = 7.days
      INGRESS_NGINX_VERSION = '0.27.1'.freeze

      INGRESS_SETUP_RESOURCES = [
        "https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-#{INGRESS_NGINX_VERSION}/deploy/static/mandatory.yaml",
        "https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-#{INGRESS_NGINX_VERSION}/deploy/static/provider/cloud-generic.yaml"
      ].freeze

      attr_reader :definition, :config

      def initialize(definition)
        @definition = definition
        @config = Config.new
      end

      def configure(&block)
        config.instance_eval(&block)
      end

      def setup
        Kuby.logger.info(ColorizedString['Starting setup...'].yellow)
        setup_nginx_ingress
        Kuby.logger.info(ColorizedString['Setup complete!'].yellow)
      rescue => e
        puts ColorizedString['Setup failed'].red
      end

      def deploy
        deployer.deploy
      end

      def kubernetes_cli
        @kubernetes_cli ||= Kuby::Kubernetes::CLI.new(kubeconfig_path).tap do |cli|
          cli.before_execute do
            FileUtils.mkdir_p(kubeconfig_dir)
            refresh_kubeconfig
          end
        end
      end

      def kubeconfig_path
        @kubeconfig_path ||= kubeconfig_dir.join(
          "#{definition.app_name.downcase}-kubeconfig.yaml"
        )
      end

      private

      def setup_nginx_ingress
        Kuby.logger.info(ColorizedString['Deploying nginx ingress resources'].yellow)

        INGRESS_SETUP_RESOURCES.each do |uri|
          kubernetes_cli.apply_uri(uri)
        end

        Kuby.logger.info(ColorizedString['Nginx ingress resources deployed!'].yellow)
      rescue => e
        Kuby.logger.fatal(ColorizedString[e.message].red)
        raise
      end

      def client
        @client ||= DropletKit::Client.new(
          access_token: config.access_token
        )
      end

      def deployer
        @deployer ||= Kuby::Kubernetes::Deployer.new(
          definition.kubernetes.resources, kubernetes_cli
        )
      end

      def refresh_kubeconfig
        return unless should_refresh_kubeconfig?
        Kuby.logger.info(ColorizedString['Refreshing kubeconfig...'].yellow)
        kubeconfig = client.kubernetes_clusters.kubeconfig(id: config.cluster_id)
        File.write(kubeconfig_path, kubeconfig)
        Kuby.logger.info(ColorizedString['Successfully refreshed kubeconfig!'].yellow)
      end

      def should_refresh_kubeconfig?
        !File.exist?(kubeconfig_path) ||
          (Time.now - File.mtime(kubeconfig_path)) >= KUBECONFIG_EXPIRATION
      end

      def kubeconfig_dir
        @kubeconfig_dir ||= definition.app.root.join(
          'tmp', 'kuby-digitalocean'
        )
      end
    end
  end
end
