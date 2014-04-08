require 'kitchen/provisioner/chef_zero'

module Kitchen

  module Provisioner

    # Windows Chef Zero provisioner.
    #
    # @author Sean Porter <portertech@gmail.com>
    class WindowsChefZero < ChefZero

      default_config :sudo, false
      default_config :require_chef_omnibus, false
      default_config :root_path, 'C:\Windows\Temp\kitchen'
      default_config :ruby_bindir, 'C:\opscode\chef\embedded\bin'
      default_config :chef_bindir, 'C:\opscode\chef\bin'

      def run_command
        args = [
          "--config #{config[:root_path]}\\client.rb",
          "--log_level #{config[:log_level]}"
        ]
        if config[:chef_zero_port]
          args <<  "--chef-zero-port #{config[:chef_zero_port]}"
        end
        if config[:json_attributes]
          args << "--json-attributes #{config[:root_path]}\\dna.json"
        end
        ["#{config[:chef_bindir]}\\chef-client -z"].concat(args).join(" ")
      end

      private

      def windows_chef_client_rb
        root = config[:root_path]

        {
          :node_name        => instance.name,
          :checksum_path    => "#{root}\\checksums",
          :file_cache_path  => "#{root}\\cache",
          :file_backup_path => "#{root}\\backup",
          :cookbook_path    => ["#{root}\\cookbooks", "#{root}\\site-cookbooks"],
          :data_bag_path    => "#{root}\\data_bags",
          :environment_path => "#{root}\\environments",
          :node_path        => "#{root}\\nodes",
          :role_path        => "#{root}\\roles",
          :client_path      => "#{root}\\clients",
          :user_path        => "#{root}\\users",
          :validation_key   => "#{root}\\validation.pem",
          :client_key       => "#{root}\\client.pem",
          :chef_server_url  => "http://127.0.0.1:8889",
          :encrypted_data_bag_secret => "#{root}\\encrypted_data_bag_secret",
        }
      end

      def prepare_client_rb
        data = windows_chef_client_rb.merge(config[:client_rb])

        File.open(File.join(sandbox_path, "client.rb"), "wb") do |file|
          file.write(format_config_file(data))
        end
      end
    end
  end
end