class VenueSyncJob < ApplicationJob
  queue_as :default

  def perform(*args)
    begin
      connection = Faraday.new(url: ENV['FESTIVAL_API_URL'])
      response = connection.get("/mock_api/screenings?generation=2&page=#{rand(1..6)}&fail_after=5")

      if response.status == 500
        raise Exception.new("API Error: #{JSON.parse(response.body).fetch("error")}")
      end

      payload = JSON.parse(response.body).fetch("screenings")

      VenueSync.new(payload).call
    rescue Exception => e
      p "------------------------------------------"
      p "Error: #{e.message}"
      p "------------------------------------------"
    end
  end
end
