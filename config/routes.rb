Rails.application.routes.draw do

  scope module: :auth do
    controller :join do
      get :confirm
      get 'join' => :new
      post 'join' => :create
    end

    controller :login do
      get 'login' => :new
      post 'login' => :create
      get 'logout' => :destroy
    end

    controller :confirm do
      post 'email' => :email
      post 'mobile' => :mobile
      post 'confirm/:token' => :update
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
  end

  scope :admin, module: 'auth/admin', as: 'admin' do
    resources :users
    resources :oauth_users
  end

  scope :my, module: 'auth/my', as: 'my' do
    resource :user
    resources :oauth_users
  end

end

RailsAuth::Engine.routes.draw do

  scope module: 'auth/api', as: 'api' do
    controller :user do
      get 'join' => :new
      post 'join' => :create
      post 'login' => :create
    end
    resource :me
    resources :oauth_users, only: [:create]
  end

end
