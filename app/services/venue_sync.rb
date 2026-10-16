# Keeps our local venue records in step with the upstream festival system.
#
# Inherited from the previous programming integration. Given an array of venue
# hashes from the API, it upserts each one into our venues table.
#
#   VenueSync.new(venues_payload).call
#
# where each entry looks like:
#   { "id" => "VEN-01", "name" => "Grand Cinema", "address" => "...", "capacity" => 320 }
class VenueSync
  def initialize(screenings)
    @screenings = screenings
  end

  def call
    @screenings.each do |attrs|

      vanue_atrs = attrs["venue"]
      venue = Venue.find_or_initialize_by(external_id: vanue_atrs.fetch("id"))
      venue.name = vanue_atrs["name"]
      venue.address     = vanue_atrs["address"]
      venue.capacity    = vanue_atrs["capacity"]
      venue.save!

      film_atrs = attrs["film"]
      film = Film.find_or_initialize_by(external_id: film_atrs.fetch("id"))
      film.title = film_atrs["title"]
      film.synopsis = film_atrs["synopsis"]
      film.runtime = film_atrs["runtime"]
      film.year = film_atrs["year"]
      film.save!

      screening = Screening.find_or_initialize_by(external_id: attrs.fetch("id"))
      screening.film = film
      screening.venue = venue
      screening.starts_at = attrs["starts_at"]
      screening.status = attrs["status"]
      screening.save!
    end
  end
end
