resources :mappings do
  collection do
    post 'xhr_labels'
  end
end

# match "/pivotal_activity.xml" => PivotalHandler, :anchor => false
