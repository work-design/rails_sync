module Sync
  class Form < ApplicationRecord
    include Com::Ext::Taxon
    include Model::Form
  end
end
