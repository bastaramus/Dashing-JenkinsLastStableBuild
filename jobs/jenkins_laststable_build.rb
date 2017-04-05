require 'net/http'
require 'json'

JENKINS_URI = "http://localhost:8080/"

JENKINS_AUTH = {
  'name' => nil,
  'password' => nil
}

def getFromJenkins(path)

  uri = URI.parse(path)
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.request_uri)
  if JENKINS_AUTH['name']
    request.basic_auth(JENKINS_AUTH['name'], JENKINS_AUTH['password'])
  end
  response = http.request(request)

  json = JSON.parse(response.body)
  return json
end

last_build = 0
current_build = 0

SCHEDULER.every '1m' do
  jsonStableBuild = getFromJenkins(JENKINS_URI + '/job/JOBNAME/lastStableBuild/api/json?pretty=true')
  buildDate = Time.at((jsonStableBuild['timestamp']/1000).to_i)
  last_build = current_build
  current_build = jsonStableBuild['number']
  send_event('last_build', {current_build: current_build, last_build: last_build, build_date: buildDate.strftime("%a, %d %b %H:%M")})
end
