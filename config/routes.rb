Rails.application.routes.draw do

  namespace :sync, defaults: { business: 'sync' } do
    namespace :admin, defaults: { namespace: 'admin' } do
      resources :audits do
        post :sync, on: :collection
        post :batch, on: :collection
        patch :apply, on: :member
      end
    end
  end

end
