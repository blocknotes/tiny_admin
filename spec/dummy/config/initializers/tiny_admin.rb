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

# TinyAdmin.configure do |settings|
#   settings.authentication = {
#     plugin: TinyAdmin::Plugins::SimpleAuth
#   }

#   settings.root = {
#     page: 'RootPage',
#     title: 'Test Admin'
#   }

#   settings.sections = [
#     {
#       slug: 'google',
#       name: 'Google.it',
#       type: :url,
#       url: 'https://www.google.it'
#     },
#     {
#       slug: 'sample',
#       name: 'Sample page',
#       type: :page,
#       page: 'SamplePage'
#     },
#     {
#       slug: 'authors',
#       name: 'Authors',
#       type: :resource,
#       model: 'Author'
#     },
#     {
#       slug: 'posts',
#       name: 'Posts',
#       type: :resource,
#       model: 'Post',
#       only: %i[index show]
#     }
#   ]

#   settings.scripts = [
#     { src: '/bootstrap.bundle.min.js' }
#   ]
# end
