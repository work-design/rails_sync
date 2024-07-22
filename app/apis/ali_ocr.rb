begin
  require 'aliyunsdkcore'
rescue LoadError
end

class AliOcr
  attr_reader :client

  def initialize(key, secret)
    @client = RPCClient.new(
      endpoint: 'https://documentautoml.cn-beijing.aliyuncs.com',
      api_version: '2022-12-29',
      access_key_id: key,
      access_key_secret: secret
    )
  end

  def records
    body = {
      action: 'DescribeDomainRecords'
    }
    body.merge! params: {
      DomainName: root_domain
    }
    body.merge! opts: {
      method: 'POST',
      timeout: 15000
    }

    client.request(**body)
  end



end
