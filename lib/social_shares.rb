require 'social_shares/version'
require 'social_shares/base'

require 'rest-client'
require 'json'

module SocialShares
  autoload :Facebook,      'social_shares/facebook'
  autoload :Google,        'social_shares/google'
  autoload :Twitter,       'social_shares/twitter'
  autoload :MailRu,        'social_shares/mail_ru'
  autoload :Odnoklassniki, 'social_shares/odnoklassniki'
  autoload :Reddit,        'social_shares/reddit'
  autoload :Linkedin,      'social_shares/linkedin'
  autoload :Pinterest,     'social_shares/pinterest'
  autoload :Stumbleupon,   'social_shares/stumbleupon'

  class << self
    SUPPORTED_NETWORKS = [
      :vkontakte,
      :facebook,
      :google,
      :twitter,
      :mail_ru,
      :odnoklassniki,
      :reddit,
      :linkedin,
      :pinterest,
      :stumbleupon
    ]

    def supported_networks
      SUPPORTED_NETWORKS
    end

    SUPPORTED_NETWORKS.each do |network_name|
      define_method(network_name) do |url|
        class_name = network_name.to_s.split('_').map(&:capitalize).join
        SocialShares.const_get(class_name).new(url).shares
      end

      define_method("#{network_name}!") do |url|
        class_name = network_name.to_s.split('_').map(&:capitalize).join
        SocialShares.const_get(class_name).new(url).shares!
      end
    end

    def selected(url, selected_networks)
      filtered_networks(selected_networks).inject({}) do |result, network_name|
        result[network_name] = self.send(network_name, url)
        result
      end
    end

    def selected!(url, selected_networks)
      filtered_networks(selected_networks).inject({}) do |result, network_name|
        result[network_name] = self.send("#{network_name}!", url)
        result
      end
    end

    def all(url)
      selected(url, SUPPORTED_NETWORKS)
    end

    def all!(url)
      selected!(url, SUPPORTED_NETWORKS)
    end

    def total(url, selected_networks = SUPPORTED_NETWORKS)
      selected!(url, selected_networks).values.reduce(:+)
    end

    def has_any?(url, selected_networks = SUPPORTED_NETWORKS)
      !filtered_networks(selected_networks).find{|n| self.send("#{n}!", url) > 0}.nil?
    end

  private

    def filtered_networks(selected_networks)
      selected_networks.map(&:to_sym) & SUPPORTED_NETWORKS
    end
  end
end
