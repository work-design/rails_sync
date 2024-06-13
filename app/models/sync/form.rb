module Qingflow
  class Form < ApplicationRecord
    include Com::Ext::Taxon
    include Model::Form
  end
end
