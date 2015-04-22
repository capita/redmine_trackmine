resources :mappings, except: :show

get 'mappings/update_labels', to: 'mappings#update_labels'