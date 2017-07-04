Gem::Specification.new do |s|
  s.name = 'mns_timeline'
  s.version = '0.2.0'
  s.summary = 'Subscribes to the SPS topic *timeline/add*, fetches the ' + 
      'topic, message + id and posts it to the timeline feed'
  s.authors = ['James Robertson']
  s.files = Dir['lib/mns_timeline.rb']
  s.add_runtime_dependency('sps-sub', '~> 0.3', '>=0.3.5')
  s.add_runtime_dependency('daily_notices', '~> 0.6', '>=0.6.2')
  s.add_runtime_dependency('recordx_sqlite', '~> 0.2', '>=0.2.7')  
  s.signing_key = '../privatekeys/mns_timeline.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/mns_timeline'
end
