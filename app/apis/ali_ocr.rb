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

  def ocr_template(file, task_id:)
    body = {
      action: 'PredictTemplateModel'
    }
    body.merge! opts: {
      method: 'POST',
      timeout: 15000
    }
    body.merge! params: {
      TaskId: task_id,
      Body: file,
      BinaryToText: true
    }

    r = client.request(**body)
    r.dig('Data', 'data').each_with_object({}) do |i, h|
      h.merge! i['fieldName'] => i['fieldWordRaw']
    end
  end

  def ocr_223(file, class_id: 223)
    body = {
      action: 'PredictClassifierModel'
    }
    body.merge! opts: {
      method: 'POST',
      timeout: 15000
    }
    body.merge! params: {
      ClassifierId: class_id,
      Body: file,
      BinaryToText: true
    }

    r = client.request(**body)
    r.dig('Data', 'data').map do |i|
      [i['fieldName'], i['fieldWordRaw']]
    end.to_h
  end

  def ocr_233(file, class_id: 233)
    body = {
      action: 'PredictClassifierModel'
    }
    body.merge! opts: {
      method: 'POST',
      timeout: 15000
    }
    body.merge! params: {
      ClassifierId: class_id,
      Body: file,
      BinaryToText: true
    }

    r = client.request(**body)

    if r['Data'].key?('data')
      [r['Data']['data']]
    else
      r['Data']['tablesInfo'][0]['rowsInfo'].map { |row| row.map(&->(i){ [i['fieldName'], i['fieldWord']] }).to_h }
    end
  end



end
