# frozen_string_literal: true

Rails.application.routes.draw do
  get '/:locale', locale: Regexp.union(I18n.available_locales.map(&:to_s)), to: 'static#feed', as: :locale_root

  # Devise omniauth callbacks can't be scoped
  devise_for :users,
             only: :omniauth_callbacks,
             controllers: { omniauth_callbacks: 'users/omniauth_callbacks' },
             path: ''

  scope '(:locale)', locale: Regexp.union(I18n.available_locales.map(&:to_s)) do
    root 'static#feed'
    
    # Devise
    devise_for :users,
               controllers: {
                 registrations: 'users/registrations', sessions: 'users/sessions',
                 passwords: 'users/passwords', confirmations: 'users/confirmations'
               },
               skip: :omniauth_callbacks,
               path: '',
               path_names: {
                 sign_in: 'login', sign_out: 'logout', sign_up: 'signup',
                 password: 'forgot_password', confirmation: 'confirm_account'
               }

    # Static pages
    get 'about', to: 'static#about', as: :page_static_about

    # Profile
    resources :profiles, only: %i[show edit update], param: :username

    # Account
    get '/account', to: 'account#edit'
    patch '/account', to: 'account#update'

    # Clan
    resources :clans do
      member do
        post :join
        post :primary
      end
    end

    # Preferences
    get '/preferences',   to: 'preferences#edit'
    patch '/preferences', to: 'preferences#update'

    # Language
    resources :languages do
      resources :words, path: 'dictionary', path_names: { new: 'add' } do
        get 'settings', on: :member
      end
    end

    # Phones
    resources :phones

	# Sidebar functions
	resources :sidebar do
	  get :xs_to_ipa, on: :member
	end
	
    # Wordlinks
    resources :wordlinks

    # Admin
    namespace :admin do
      # Admin::Langtypes
      resources :langtypes, only: %i[index edit update]
    end
  end
end
