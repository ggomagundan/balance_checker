require 'aws-sdk-dynamodb'
require 'google/cloud/datastore'
require 'poloniex'
require 'dotenv/load'
require 'pry'

Poloniex.setup do | config |
    config.key = ENV['POLONIEX_KEY']
    config.secret = ENV['POLONIEX_SECRET']
end

class PoloniexChecker
  def self.get_balance
    JSON.parse(Poloniex.balances.body)
  end

  def self.get_available_lending_balance(currency = 'BTC')
    JSON.parse(Poloniex.available_account_balances.body).dig("lending").dig(currency.upcase)
  end

  def self.get_current_lending_orders(currency = 'BTC')
    JSON.parse(Poloniex.loan_orders(currency.upcase).body)
  end

  def self.get_best_lending_offer(currency = 'BTC')
    offers = self.get_current_lending_orders(currency.upcase).dig("offers").map{|d| d.dig("rate")}.sort.uniq
    puts "Offers = #{offers}"
    #offers.each_with_index do |tick, index|
    #  if (offers[index + 1].to_d - tick.to_d).to_f == 0.0001
    #    return tick
    #  end
    #end
    offers.first
  end

  def self.make_lending_order_with_divide(currency = 'BTC', divide = 3)
    available_balance = PoloniexChecker.get_available_lending_balance(currency)
    if available_balance.nil?
      puts "No balance to #{currency}'s lending balance"
      return
    end
    puts "#{currency}'s available lending balance : #{available_balance}"
    divided_value = (available_balance.to_f / divide).floor(8)
    puts "#{currency}'s order lending balance : #{divided_value}"
    unless check_divide_value(divided_value, currency)
      puts "Not enough #{currency}'s order lending balance : #{divided_value}"
    else
      # Poloniex.make_loan_offer("BTC", 0.01, 2, 0, PoloniexChecker.get_best_lending_offer)
      order_result = Poloniex.make_loan_offer(currency.upcase, divided_value, 2, 0, PoloniexChecker.get_best_lending_offer(currency.upcase).to_f)
      order_result.body
    end
  end

  def self.check_divide_value(divided_value, currency='BTC')
    case currency.upcase
    when 'BTC'
      return divided_value > 0.01
    when 'ETH'
      return divided_value > 0.1
    else
      return false
    end
  end

  def self.my_loan_orders
    Poloniex.open_loan_offers.body
  end

  def self.save_balance_to_dynamo
    dynamodb = Aws::DynamoDB::Client.new
    dynamodb.put_item({
      table_name: 'exchange_data',
      item: {
      id: SecureRandom.uuid,
      data: PoloniexChecker.get_balance,
      datetime:  DateTime.now.to_time.utc.strftime("%Y%m%d_%H%M"),
      exchange: 'poloniex'
      },
      return_values: "ALL_OLD", # accepts NONE, ALL_OLD, UPDATED_OLD, ALL_NEW,
    })
  end

  def self.save_balance_to_datastore
    datastore = Google::Cloud::Datastore.new project: 'exchange-analyzer'
    datastore.transaction do |tx|
      exchange_data = datastore.entity "exchange_data" do |t|
        prop = Google::Cloud::Datastore::Properties.new(self.get_balance)
        t['data'] = Google::Cloud::Datastore::Entity.from_grpc Google::Datastore::V1::Entity.new( properties: prop.to_grpc)
        t['datetime']=  DateTime.now.to_time.utc
        t['exchange']= 'poloniex'
        t.exclude_from_indexes! "description", true
      end
      datastore.save exchange_data
    end
  end

  def self.save_balance_to_aws_gcp
    puts self.save_balance_to_dynamo
    puts self.save_balance_to_datastore
  end
end
