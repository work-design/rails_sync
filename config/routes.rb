Rails.application.routes.draw do

  namespace :sync, defaults: { business: 'sync' } do
    namespace :admin, defaults: { namespace: 'admin' } do
      resources :audits do
        post :sync, on: :collection
        post :batch, on: :collection
        patch :apply, on: :member
      end
      resources :apps do
        resources :forms do
          collection do
            post :sync
          end
        end
        resources :items do
          collection do
            post :sync
          end
          member do
            post :refresh
          end
          resources :logs
        end
      end

    end
  end

end
