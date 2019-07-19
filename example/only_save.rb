require '../poloniex_checker.rb'

# puts PoloniexChecker.get_balance
puts "started ......"
puts Time.now.strftime("%Y.%m.%d %H:%M:%S")
puts "Save poloniex balances"
# call PoloniexChecker.save_balance_to_dynamo
# And PoloniexChecker.save_balance_to_aws_gcp
puts PoloniexChecker.save_balance_to_aws_gcp
puts "ended ......"
puts Time.now.strftime("%Y.%m.%d %H:%M:%S")
puts "\n\n"
