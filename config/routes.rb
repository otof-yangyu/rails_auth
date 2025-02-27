Rails.application.routes.draw do

  scope module: :auth do

    controller :sign do
      match :sign, via: [:get, :post]
      post 'sign/token' => :token
      post 'sign/mock' => :mock
      post :login
      get :logout
    end
    
    controller :wechat do
      post 'wechat/auth' => :auth
    end

    scope :password, controller: :password, as: 'password' do
      get 'forget' => :new
      post 'forget' => :create
      scope as: 'reset' do
        get 'reset/:token' => :edit
        post 'reset/:token' => :update
      end
    end

    scope :auth, controller: :oauths do
      match ':provider/callback' => :create, via: [:get, :post]
      match ':provider/failure' => :failure, via: [:get, :post]
    end
    resources :users, only: [:index, :show]
  end

  scope :admin, module: 'auth/admin', as: 'admin' do
    resources :users do
      get :panel, on: :collection
      post :mock, on: :member
    end
    resources :oauth_users
    resources :accounts
    resources :user_tags
  end

  scope :my, module: 'auth/mine', as: 'my' do
    resource :user
    resources :accounts do
      member do
        get 'confirm' => :edit_confirm
        post 'confirm' => :update_confirm
      end
    end
    resources :oauth_users do
      collection do
        get :bind
      end
    end
  end

end
