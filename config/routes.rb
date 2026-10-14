Rails.application.routes.draw do
  # Health check for kamal-proxy
  get "up" => "rails/health#show", as: :rails_health_check

  # Root route
  root "admin/grades#index"

  # Login routes
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  resources :head_imgs

  resources :mps
  resources :feedbacks, only: [:index]

  resources :files, only: [:show] do
    collection do
      post :upload
      post :upload_img
      post :upload_open_img
      post :upload_media
    end
  end

  resources :grades, only: [:index] do
    get 'options', on: :collection

    resources :ranks do
      resources :rank_contents
    end
  end

  namespace :statistic do
    resources :grade_reports, only: [:index]
    resources :channel_reports, only: [:index] do
      get 'export', on: :collection, :defaults => {:format => 'xls'}
    end

    resources :user_analytics_daily_reports, only: [:index] do
      get 'export', on: :collection, :defaults => {:format => 'xls'}
    end
  end

  # Admin routes
  namespace :admin do
    resources :options, only: [:index]
    resources :user_stats, only: [:index]
    resources :authors do
      get 'batch_new', on: :collection
      post 'batch_add', on: :collection
    end

    resources :accounts, only: [:index, :new, :create, :edit, :update, :show, :destroy] do
      member do
        post :reset_password
      end
    end

    resources :permissions, only: [:index, :show]
    resources :suppliers
    resources :channels

    resources :categories do
      resources :category_subs do
        post 'update_sn', on: :collection
      end
      member do
        get :subs
      end
    end

    resources :book_levels

    resources :grades do
      resources :recommends, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
        member do
          post :toggle_status
        end
        collection do
          post :upload_cover
        end

        resources :content_groups do
          resources :contents
        end
      end
    end

    # Collections management (绘本合辑)
    resources :compilations, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
      resources :books
      #member do
      #  get 'books'
      #  post 'update_books'
      #end
    end

    resources :picture_books do
      get 'media_link', on: :member
      put 'update_media_link', on: :member
      resources :catalogues do
        post 'update_sn', on: :collection
        post 'batch_free', on: :collection
        post 'batch_unfree', on: :collection
      end
      resources :ebook_pages do
        post 'batch_free', on: :collection
        post 'batch_unfree', on: :collection
      end
    end

    resources :media_books do
      resources :chapters do
        post 'update_sn', on: :collection
        post 'batch_free', on: :collection
        post 'batch_unfree', on: :collection

        get 'batch_new', on: :collection
        post 'batch_add', on: :collection
      end
      post 'auto_sort', on: :member
    end
  end

  namespace :operator do
    resources :packages
    resources :orders, only: [:index] do
      get 'export', on: :collection, :defaults => {:format => 'xls'}
    end
    resources :app_users, only: [:index] do
      get 'new_gift_vip', on: :member
      put 'add_gift_vip', on: :member
      get 'export', on: :collection, :defaults => {:format => 'xls'}
    end
  end

  resources :push_notifications, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    member do
      post :send_push
    end
  end

  resources :splash_ads do
    member do
      post :publish
      post :disable
      post :enable
    end
  end
end
