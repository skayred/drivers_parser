require 'open-uri'
require 'nokogiri'
require 'json'

@domain = 'http://www.taxodrom.ru%s';
generic_url = 'http://www.taxodrom.ru/private-taxi?page=%d'
start_number = 0
end_number = 2

drivers = Array.new

def parse_name(info)
  anchor = info.xpath('a')[0]
  return @domain % anchor['href'], anchor.text.strip
end

def parse_phone(info)
  info.text.strip
end

def parse_car_model(info)
  info.xpath('span').each do |node|
    node.remove
  end

  #info.children.remove
  info.text.strip
end

def parse_price_per_km(info)
  info.text.strip
end

def parse_price_per_min(info)
  info.text.strip
end

def parse_wait_price(info)
  info.text.strip
end

def parse_min_price(info)
  info.text.strip
end

def parse_location(info)
  result = ""

  info.xpath('div').each do |location|
    result << " " << location.text.strip
  end

  result.strip
end

def parse_updated_at(info)
  info.text.strip
end

for i in start_number..end_number do
  puts "Page: #{i}"

  page_url = generic_url % i

  doc = Nokogiri::HTML(open(page_url))

  doc.xpath('//table[@class = "views-taxi-private-table"]/tbody/tr').each do |node|
    driver_details_url = ""
    name = ""
    phone = ""
    car_model = ""
    price_per_km = ""
    price_per_min = ""
    wait_price = ""
    min_price = ""
    updated_at = ""
    location = ""
    email = ""
    auto_class = ""
    about = ""

    node.xpath('td').each do |info|
      if info['class'] == "views-field views-field-title"
        driver_details_url, name = parse_name(info)
      elsif info['class'] == "views-field views-field-field-private-car-phone-value"
        phone = parse_phone(info)
      elsif info['class'] == "views-field views-field-field-private-car-model-value"
        car_model = parse_car_model(info)
      elsif info['class'] == "views-field views-field-field-private-car-tarif-a-value"
        price_per_km = parse_price_per_km(info)
      elsif info['class'] == "views-field views-field-field-private-car-tarif-b-value"
        price_per_min = parse_price_per_min(info)
      elsif info['class'] == "views-field views-field-field-private-car-tarif-c-value"
        wait_price = parse_wait_price(info)
      elsif info['class'] == "views-field views-field-field-private-car-tarif-d-value"
        min_price = parse_min_price(info)
      elsif info['class'] == "views-field views-field-field-private-car-dislocation-value"
        location = parse_location(info)
      elsif info['class'] == "views-field views-field-last-update-time"
        updated_at = parse_updated_at(info)
      end
    end

    if (driver_details_url != '')
      details = Nokogiri::HTML(open(driver_details_url))

      email_anchor = details.xpath('//dl[@class = "private-car-user-info"]/dd/a')[0]

      if email_anchor != nil
        email = email_anchor.text
      end

      auto_class = details.xpath('//dl[@class = "private-car-user-info"]/dd')[3].text.strip

      about_holder = details.xpath('//div[@id = "private-car-dop-info"]/div/p')[0]

      if about_holder != nil
        about = about_holder.text
      end
    end

    driver = {
        :name => name,
        :phone => phone,
        :car_model => car_model,
        :price_per_km => price_per_km,
        :price_per_min => price_per_min,
        :wait_price => wait_price,
        :min_price => min_price,
        :location => location,
        :email => email,
        :auto_class => auto_class,
        :updated_at => updated_at,
        :source => driver_details_url,
        :about => about
    }

    drivers << driver
  end
end

puts drivers.to_json

drivers_file = File.new("drivers.json", "w")
drivers_file.puts drivers.to_json
