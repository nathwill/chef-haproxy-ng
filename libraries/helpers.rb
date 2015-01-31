module Haproxy
  module Helpers
    def self.config_blob(config = {})
      blog = []

      config.each_pair do |param, val|
        Array(val).each do |v|
          blob << "#{param} #{v}"
        end
      end

      blob.join("\n")
    end
  end
end
