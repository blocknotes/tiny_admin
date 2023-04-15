Rails.application.config.to_prepare do
  config = Rails.root.join('config/tiny_admin.yml').to_s
  TinyAdmin.configure_from_file(config)

  # Settings can also be changed programmatically
  TinyAdmin.configure do |settings|
    settings.authentication[:password] = Digest::SHA512.hexdigest('changeme')
    # or
    # settings.authentication[:password] = 'f1891cea80fc05e433c943254c6bdabc159577a02a7395dfebbfbc4f7661d4af56f2d372131a45936de40160007368a56ef216a30cb202c66d3145fd24380906'

    settings.scripts = [
      { src: '/bootstrap.bundle.min.js' }
    ]
  end
end
