require "sinatra"
require "nokogiri"
require "json"

GITHUB_HOST = "https://github.com"
GITHUB_API_HOST = "https://api.github.com"

get '/' do
  'hello world'
end

get '/trending' do
  content_type 'application/json'
  uri = URI.parse("#{GITHUB_HOST}/trending")
  github_trending_html = get_response_body(uri)
  repos = []

  github_trending_html.css('ol.repo-list li').each do |repo_html|
    repos.push(generate_repo(repo_html))
  end

  JSON.pretty_generate(repos)
end

get '/trending/:language' do
  content_type 'application/json'
  language = params[:language]
  uri = URI.parse("#{GITHUB_HOST}/trending/#{language}")
  github_trending_html = get_response_body(uri)
  repos = []

  github_trending_html.css('ol.repo-list li').each do |repo_html|
    repos.push(generate_repo(repo_html))
  end

  JSON.pretty_generate(repos)
end

def get_response_body(uri)
  response = Net::HTTP.get_response(uri)
  Nokogiri::HTML(response.body)
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
