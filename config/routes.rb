Rails.application.routes.draw do

  scope :admin, as: 'admin', module: 'the_sync_admin' do
    resources :sync_audits
  end

end
