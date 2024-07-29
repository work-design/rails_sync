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

  def ocr(class_id: 223, url: 'https://test.work.design/shurui2.jpg')
    body = {
      action: 'PredictClassifierModel'
    }
    body.merge! opts: {
      method: 'POST',
      timeout: 15000
    }
    body.merge! params: {
      ClassifierId: class_id,
      Content: url
    }

    r = client.request(**body)
    r.dig('Data', 'data').map do |i|
      [i['fieldName'], i['fieldWordRaw']]
    end.to_h
  end



end
