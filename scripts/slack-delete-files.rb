require 'net/http'
require 'json'
require 'uri'

# Script Configuration
@token = ''

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

def delete_files(file_ids)
  file_ids.each do |file_id|
    params = {
        token: @token,
        file: file_id
    }

    uri = URI.parse('https://slack.com/api/files.delete')
    uri.query = URI.encode_www_form(params)
    Net::HTTP.get_response(uri)

    print "#{file_id} "
  end
end

def delete_all_files
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

    delete_files(file_ids)
  end
end

puts 'Deleting...'
delete_all_files
puts 'Done!'

