module OpengraphPreview
  extend ActiveSupport::Concern

  TRUSTED_CIDRS = ENV.fetch("OPENGRAPH_TRUSTED_CIDRS", "").split(",").map { |cidr| IPAddr.new(cidr.strip) }.freeze

  private
    def trusted_ip?
      return false if TRUSTED_CIDRS.empty?
      address = IPAddr.new(request.remote_ip)
      TRUSTED_CIDRS.any? { |cidr| cidr.include?(address) }
    rescue IPAddr::InvalidAddressError
      false
    end

    def require_trusted_ip
      head :forbidden unless trusted_ip?
    end
end
