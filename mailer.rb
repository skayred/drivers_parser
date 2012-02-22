# encoding: utf-8

require 'mail'
require 'json'

smtp_conn = Net::SMTP.new('smtp.gmail.com', 587)
smtp_conn.enable_starttls
smtp_conn.start('smtp.gmail.com', MY_EMAIL, MY_PASSWORD, :plain)

Mail.defaults do
  delivery_method :smtp_connection, { :connection => smtp_conn }
end

json = File.read('drivers.json')
drivers = JSON.parse(json)

@letter_template = File.read('letter_template.html')

def send_letter(email, name)
  letter = @letter_template % name

  mail = Mail.new do
    to email
    from "\"Jet Taxi\" <dmitry@jettaxi.mobi>"
    subject 'Добро пожаловать в Такси Джет!'
    html_part do
      content_type 'text/html; charset=UTF-8'
      body letter
    end
  end

  mail.deliver!
end

drivers.each do |driver|
  puts "Name: %s" % driver["name"]
  puts "Email: %s" % driver["email"]
end

send_letter("to@gmail.com", 'TO')