require 'net/http'
require 'json'
require 'uri'
require 'open-uri'

# Script Configuration
@token = ''
@target_location = ''

def files_info(page)
  params = {
      token: @token,
      count: 100,
      page: page
  }

  uri = URI.parse('https://slack.com/api/files.list')
  uri.query = URI.encode_www_form(params)

  response = Net::HTTP.get_response(uri)
  JSON.parse(response.body)
end

def download_files(file_ids)
  file_ids.each do |file_id|
    params = {
        token: @token,
        file: file_id
    }

    uri = URI.parse('https://slack.com/api/files.info')
    uri.query = URI.encode_www_form(params)

    response = Net::HTTP.get_response(uri)
    json_response = JSON.parse(response.body)

    file_name = "#{@target_location}/#{file_id}-#{json_response['file']['name']}"
    f = File.new(file_name, 'w')
    f.close

    download = open(json_response['file']['url_private_download'])
    IO.copy_stream(download, file_name)

    print "#{file_id} "
  end
end

def download_all_files()
  verify_files = files_info(1)

  total = verify_files['paging']['total']
  puts "Total: #{total}"

  total.times do |n|
    page = n + 1
    puts "Page [#{page}]----------------"

    info = files_info(page)
    puts "#{info['paging']}"

    files = info['files']
    file_ids = files.map { |f| f['id'] }

    download_files(file_ids)
  end
end

# Process
puts 'Downloading...'
download_all_files
puts 'Done!'

