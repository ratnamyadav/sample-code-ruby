require 'rubygems'
  require 'yaml'
  require 'authorizenet' 

 require 'securerandom'

  include AuthorizeNet::API

  def charge_credit_card()
    config = YAML.load_file(File.dirname(__FILE__) + "/../credentials.yml")
  
    transaction = Transaction.new(config['api_login_id'], config['api_transaction_key'], :gateway => :sandbox)
  
    request = CreateTransactionRequest.new
  
    request.transactionRequest = TransactionRequestType.new()
    request.transactionRequest.amount = ((SecureRandom.random_number + 1 ) * 150 ).round(2)
    request.transactionRequest.payment = PaymentType.new
    request.transactionRequest.payment.creditCard = CreditCardType.new('4242424242424242','0220','123') 
    request.transactionRequest.customer = CustomerType.new(nil,'bmc@mail.com')
    request.transactionRequest.transactionType = TransactionTypeEnum::AuthCaptureTransaction
    
    response = transaction.create_transaction(request)
  
    if response != nil
      if response.messages.resultCode == MessageTypeEnum::Ok
        if response.transactionResponse != nil && response.transactionResponse.messages != nil
          puts "Successful charge (auth + capture) (authorization code: #{response.transactionResponse.authCode})"
          puts "Transaction Response code : #{response.transactionResponse.responseCode}"
          puts "Code : #{response.transactionResponse.messages.messages[0].code}"
		      puts "Description : #{response.transactionResponse.messages.messages[0].description}"
        else
          puts "Transaction Failed"
          if response.transactionResponse.errors != nil
            puts "Error Code : #{response.transactionResponse.errors.errors[0].errorCode}"
            puts "Error Message : #{response.transactionResponse.errors.errors[0].errorText}"
          end
          raise "Failed to charge card."
        end
      else
        puts "Transaction Failed"
        if response.transactionResponse != nil && response.transactionResponse.errors != nil
          puts "Error Code : #{response.transactionResponse.errors.errors[0].errorCode}"
          puts "Error Message : #{response.transactionResponse.errors.errors[0].errorText}"
        else
          puts "Error Code : #{response.messages.messages[0].code}"
          puts "Error Message : #{response.messages.messages[0].text}"
        end
        raise "Failed to charge card."
      end
    else
      puts "Response is null"
      raise "Failed to charge card."
    end
    
    return response
end
  
if __FILE__ == $0
  charge_credit_card()
end