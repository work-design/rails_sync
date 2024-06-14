Rails.application.routes.draw do

  namespace :sync, defaults: { business: 'sync' } do
    resources :items, only: [:index, :create] do
      collection do
        match '/' => :update, via: [:put, :patch]
      end
    end

    namespace :admin, defaults: { namespace: 'admin' } do
      root 'home#index'
      resources :audits do
        post :sync, on: :collection
        post :batch, on: :collection
        patch :apply, on: :member
      end
      resources :apps do
        resources :records do
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
              post :migrate
            end
            resources :logs
          end
        end
      end

    end
  end

end
