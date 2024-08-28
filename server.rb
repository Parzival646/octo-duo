require 'sinatra'
require 'stripe'
# This is your test secret API key.
Stripe.api_key = 'sk_test_51Psn9yGO0lVdSd8Ut1MUmXt9PQJq8lvIPeRrn8Z0zBAG7EQ9Rw6erqVKlOic7cL9qeJFnamnSi1ghwD8jiKu8E5300l5IYBfpl'

set :static, true
set :port, 4242

# Securely calculate the order amount
def calculate_order_amount(_items)
  # Calculate the order total on the server to prevent
  # people from directly manipulating the amount on the client
  _items.sum {|h| h['amount']}
end

# An endpoint to start the payment process
post '/create-payment-intent' do
  content_type 'application/json'
  data = JSON.parse(request.body.read)

  # Create a PaymentIntent with amount and currency
  payment_intent = Stripe::PaymentIntent.create(
    amount: calculate_order_amount(data['items']),
    currency: 'brl',
    # In the latest version of the API, specifying the `automatic_payment_methods` parameter is optional because Stripe enables its functionality by default.
    automatic_payment_methods: {
      enabled: true,
    },
  )

  {
    clientSecret: payment_intent.client_secret,
  }.to_json
end

