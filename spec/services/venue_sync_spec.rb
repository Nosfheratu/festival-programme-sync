require "rails_helper"

RSpec.describe VenueSync do
  describe "#call" do
    it "creates a venue that doesn't exist yet" do
      payload = [
        {
          "id": "SCR-0001",
          "starts_at": "2027-03-06T16:00:00Z",
          "status": "scheduled",
          "film": {
            "id": "FILM-001",
            "title": "The Silent Orchard",
            "synopsis": "A beekeeper's last summer in the hills.",
            "runtime": 118,
            "year": 2024
          },
          "venue": {
            "id": "VEN-01",
            "name": "Grand Cinema",
            "address": "12 Main Street",
            "capacity": 320
          }
        },
        {
          "id": "SCR-0002",
          "starts_at": "2027-03-07T18:00:00Z",
          "status": "scheduled",
          "film": {
            "id": "FILM-002",
            "title": "Northern Lights Over Naples",
            "synopsis": "Two strangers share one impossible night.",
            "runtime": 102,
            "year": 2023
          },
          "venue": {
            "id": "VEN-02",
            "name": "Riverside Cinema",
            "address": "4 Quay Road",
            "capacity": 180
          }
        }
      ]

      expect { VenueSync.new(JSON.parse(payload.to_json)).call }.to change(Screening, :count).by(2)
#
      screening = Screening.find_by(external_id: "SCR-0001")
      expect(screening).to have_attributes(status: "scheduled", starts_at: "2027-03-06T16:00:00Z".to_time)
    end

    context "the venue was just renamed" do
      it "updates a venue name that already exists" do

        pending "I'll be back to this spec later 😎"

        origial_payload = [
          { "id" => "VEN-01", "name" => "Grand Cinema", "address" => "12 Main Street", "capacity" => 320 }
        ]

        expect { VenueSync.new(origial_payload).call }.to change(Venue, :count).by(1)

        new_name_payload = [
          { "id" => "VEN-01", "name" => "Grand Movil Cinema", "address" => "12 Main Street", "capacity" => 320 }
        ]

        # Resync
        expect { VenueSync.new(new_name_payload).call }.to change(Venue, :count).by(0)

        venue = Venue.find_by(external_id: "VEN-01")
        expect(venue).to have_attributes(
          name: "Grand Movil Cinema",
          address: "12 Main Street",
          capacity: 320
        )
      end
    end
  end
end
