resources :mappings do
  collection do
    get 'xhr_labels'
  end
end

match "/pivotal_activity.xml" => PivotalHandler, :anchor => false
