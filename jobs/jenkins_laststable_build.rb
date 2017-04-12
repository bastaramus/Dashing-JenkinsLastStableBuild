require 'net/http'
require 'json'

JENKINS_URI = "http://localhost:8080/"

JENKINS_AUTH = {
  'name' => nil,
  'password' => nil
}

JOB_LIST = [
        {:widget_id => 'last_build_jobname1', :job_path => 'job/JOBNAME1'},
        {:widget_id => 'last_build_jobname2', :job_path => 'job/CATALOG/job/JOBNAME2'}
]


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

JOB_LIST.each do |job|
  job[:last_build] = 0
  job[:current_build] = 0
  SCHEDULER.every '1m' do
    jobpath = job[:job_path]
    jsonStableBuild = getFromJenkins(JENKINS_URI + "#{jobpath}/lastStableBuild/api/json?pretty=true")
    buildDate = Time.at((jsonStableBuild['timestamp']/1000).to_i)
    job[:last_build] = job[:current_build]
    job[:current_build] = jsonStableBuild['number']
    send_event(job[:widget_id], {current_build: job[:current_build], last_build: job[:last_build], build_date: buildDate.strftime("%a, %d %b %H:%M")})
  end
end
