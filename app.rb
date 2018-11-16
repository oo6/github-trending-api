require "sinatra"
require "nokogiri"
require "json"
require "net/http"

GITHUB_HOST = "https://github.com"
GITHUB_API_HOST = "https://api.github.com"
SINCE_HASH = {
  "daily" => "daily",
  "weekly" => "weekly",
  "monthly" => "monthly",
}

get '/' do
  'hello world'
end

get '/trending' do
  content_type 'application/json'

  since = normalize_params_since(params[:since])
  uri = URI.parse("#{GITHUB_HOST}/trending?since=#{since}")
  repos = generate_repos(get_response_body(uri))

  JSON.pretty_generate(repos)
end

get '/trending/:language' do
  content_type 'application/json'

  since = normalize_params_since(params[:since])
  uri = URI.parse("#{GITHUB_HOST}/trending/#{params[:language]}?since=#{since}")
  repos = generate_repos(get_response_body(uri))

  JSON.pretty_generate(repos)
end

not_found do
  JSON.pretty_generate({
    "message": "Trending repositories results are currently being dissected.",
    "documentation_url": "#{GITHUB_HOST}/lixu19941116/github-trending-api",
  })
end

private
def get_response_body(uri)
  response = Net::HTTP.get_response(uri)
  Nokogiri::HTML(response.body)
end

def generate_repos(github_trending_html)
  repos = []
  github_trending_html.css('ol.repo-list li').each do |repo_html|
    repos.push(generate_repo(repo_html))
  end

  raise Sinatra::NotFound if repos.empty?
  repos
end

def generate_repo(repo_html)
  full_name = repo_html.css('h3 a').first.attributes['href'].value[1..-1]
  login = full_name.split('/')[0]
  stargazers_forks_count = repo_html.css('div.f6 a')

  # puts repo_html.css('div.f6 span.float-right')

  {
    name: full_name.split('/')[1],
    full_name: full_name,
    description: repo_html.css('div.py-1 p').text.strip,
    url: "#{GITHUB_API_HOST}/repos/#{full_name}",
    html_url: "#{GITHUB_HOST}/#{full_name}",
    language: repo_html.css('div.f6 span.mr-3').text.strip,
    stargazers_count: stargazers_forks_count[0].text.strip,
    forks_count: stargazers_forks_count[1].text.strip,
    owner: {
      login: full_name.split('/')[0],
      url: "#{GITHUB_API_HOST}/users/#{login}",
      html_url: "#{GITHUB_HOST}/#{login}"
    }
  }
end

def normalize_params_since(since)
  SINCE_HASH[since] ? SINCE_HASH[since] : "daily"
end
