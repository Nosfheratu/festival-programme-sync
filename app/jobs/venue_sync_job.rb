class VenueSyncJob < ApplicationJob
  queue_as :default

  def perform(*args)
    connection = Faraday.new(url: 'http://localhost:3000')
    # response = connection.get('/mock_api/screenings')
    response = connection.get('/mock_api/screenings?generation=2')

    screenings = JSON.parse(response.body).fetch("screenings")
    payload = screenings.map{|screening| screening.fetch("venue")}

    VenueSync.new(payload).call
  end
end
