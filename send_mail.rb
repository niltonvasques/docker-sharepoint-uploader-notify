# Author: Nilton Vasques <nilton.vasques{at}openmailbox.org>
# Description: This script connect upload a file to sharepoint and send a mail with this file link
#
# SYNOPSIS
# docker run -it --rm -e FROM='test@gmail.com' -e TO='test@gmail.com' -e SUBJECT='topic' -e SHAREPOINT_LOGIN='user@mail.com' -e SHAREPOINT_PASS='pass' -e MAIL_PASS='pass' -e SHAREPOINT_URL='sharepoint.com' -e SHAREPOINT_SITE='site' -e SHAREPOINT_FOLDER='folder' -e FILE_NAME='test.file' -v $PWD:/tmp/ --name mail-app mail-sharepoint-storage

#!/usr/bin/env ruby

require 'mail'
require 'sharepoint-ruby'
require 'awesome_print'

DEFAULT_BODY_FILE = '/tmp/body'

# mail settings
$from = ENV['FROM']
$to = ENV['TO']
$subject = ENV['SUBJECT']
$mail_pass = ENV['MAIL_PASS']
$file_name = ENV['FILE_NAME']
if File.exists?(DEFAULT_BODY_FILE)
  $body = File.read(DEFAULT_BODY_FILE)
else
  $body = ENV['BODY']
end

# Sharepoint settings
$ssp_login = ENV['SHAREPOINT_LOGIN']
$ssp_pass = ENV['SHAREPOINT_PASS']
$ssp_url = ENV['SHAREPOINT_URL']
$ssp_site = ENV['SHAREPOINT_SITE']
$ssp_folder = ENV['SHAREPOINT_FOLDER']

ap ENV

site = Sharepoint::Site.new $ssp_url, $ssp_site

puts "Authenticating in sharepoint..."

site.session.authenticate $ssp_login, $ssp_pass

puts "Searching site folder..."

folder = site.folder($ssp_folder)

file_path = "/tmp/#{$file_name}"

puts "Uploading file..."
folder.add_file($file_name, File.read(file_path))
$file_link = "https://#{$ssp_url}/#{$ssp_site}/#{$ssp_folder}/#{$ssp_folder}"
items = site.list($ssp_folder).find_items(name: $file_name)

unless items.empty?
  item = items.first
  item.version0 = "1.24.3"
  item.save

  $body.gsub!(/\[LINK\]/, $file_link)
  ap $body

  options = {
    address: "smtp.gmail.com",
    port: 587,
    user_name: $from,
    password: $mail_pass,
    authentication: "plain",
    enable_starttls_auto: true
  }

  Mail.defaults do
    delivery_method :smtp, options
  end

  puts "Send mail..."
  mail = Mail.new do
    from $from
    to $to
    subject $subject
    body $body
    #add_file './code/app/app-release.file'
    #add_file 'app-release'
  end

  mail.deliver!
end
puts "done!"
