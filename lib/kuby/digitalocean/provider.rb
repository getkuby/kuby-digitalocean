require 'kuby'
require 'droplet_kit'
require 'fileutils'
require 'tmpdir'

module Kuby
  module DigitalOcean
    class Provider < ::Kuby::Kubernetes::Provider
      KUBECONFIG_EXPIRATION = 7 * 24 * 60 * 60  # 7 days
      STORAGE_CLASS_NAME = 'do-block-storage'.freeze

      attr_reader :config

      def configure(&block)
        config.instance_eval(&block) if block
      end

      def kubeconfig_path
        @kubeconfig_path ||= File.join(
          kubeconfig_dir,
          "#{environment.app_name.downcase}" \
          "-#{generate_hash(config.access_token + config.cluster_id)}" \
          "-kubeconfig.yaml"
        )
      end

      def before_setup
        refresh_kubeconfig
      end

      def after_setup
        if nginx_ingress = environment.kubernetes.plugin(:nginx_ingress)
          service = ::KubeDSL::Resource.new(
            kubernetes_cli.get_object(
              'service', nginx_ingress.namespace, nginx_ingress.service_name
            )
          )

          # Convert from Local to Cluster here so a DigitalOcean load balancer,
          # which sits in front of the ingress controller, is accessible by pods
          # running on the same node as the controller. We have to do this
          # because of a k8s bug:
          #
          # https://github.com/kubernetes/kubernetes/issues/87263
          # https://github.com/kubernetes/kubernetes/issues/66607
          #
          # Word on the street is this is fixed in v1.17 (DO is currently on 1.16).
          # Hopefully we can rip this out in the near future.
          #
          # This was discovered because cert-manager's self-check step attempts to
          # verify external access to its ACME challenge ingress/service, but times
          # out because k8s' iptables rules prevent it from going through the DO
          # load balancer and therefore nginx.
          service.contents['spec']['externalTrafficPolicy'] = 'Cluster'
          kubernetes_cli.apply(service)
        end
      end

      def before_deploy(*)
        refresh_kubeconfig
      end

      def storage_class_name
        STORAGE_CLASS_NAME
      end

      private

      def after_initialize
        @config = Config.new

        kubernetes_cli.before_execute do
          refresh_kubeconfig
        end
      end

      def client
        @client ||= DropletKit::Client.new(
          access_token: config.access_token
        )
      end

      def refresh_kubeconfig
        return unless should_refresh_kubeconfig?
        FileUtils.mkdir_p(kubeconfig_dir)
        Kuby.logger.info('Refreshing kubeconfig...')
        kubeconfig = client.kubernetes_clusters.kubeconfig(id: config.cluster_id)
        File.write(kubeconfig_path, kubeconfig)
        Kuby.logger.info('Successfully refreshed kubeconfig!')
      end

      def should_refresh_kubeconfig?
        !File.exist?(kubeconfig_path) ||
          (Time.now - File.mtime(kubeconfig_path)) >= KUBECONFIG_EXPIRATION
      end

      def kubeconfig_dir
        @kubeconfig_dir ||= File.join(
          Dir.tmpdir, 'kuby-digitalocean'
        )
      end
    end
  end
end
