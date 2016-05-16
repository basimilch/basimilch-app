require 'test_helper'

class GoogleMapsHelperTest < ActionView::TestCase

  test "embedded_map_url" do
    assert_equal "https://www.google.com/maps/embed/v1/place?q=1.2,3.4&zoom=1" +
                 "5&attribution_source=Genossenschaft+basimilch&maptype=roadm" +
                 "ap&key=abcd1234&language=de-CH",
                 embedded_map_url(depots(:valid))
  end

  test "embedded_map_url for directions" do
    url = "https://www.google.com/maps/embed/v1/directions?origin=Alte Kindha" +
          "userstrasse 3+8953+Dietikon+Switzerland&destination=Alte Kindhause" +
          "rstrasse 3+8953+Dietikon+Schweiz&mode=walking&maptype=roadmap&key=" +
          "abcd1234&language=de-CH"
    assert_equal url, embedded_map_url(
                        depots(:valid),
                        origin_geocoded_item: users(:admin)
                      )
    assert_equal url, embedded_map_url(
                        depots(:valid),
                        zoom: 100, # not taken into account for directions
                        origin_geocoded_item: users(:admin)
                      )
  end

  test "map_static_url for single item" do
    url = "http://maps.google.com/maps/api/staticmap?size=640x640&sensor=fals" +
          "e&zoom=15&scale=2&format=png&maptype=roadmap&markers=color:blue|1." +
          "2%2C3.4"
    assert_equal url, map_static_url(depots(:valid))
  end

  test "map_static_url for item array" do
    assert users(:admin).geocode
    url = "http://maps.google.com/maps/api/staticmap?size=640x640&sensor=fals" +
          "e&scale=2&format=png&maptype=roadmap&markers=color:blue|1." +
          "2%2C3.4|47.3971058%2C8.392147"
    assert_equal url, map_static_url([depots(:valid), users(:admin)])
    # not taken into account for multiple items
    assert_equal url, map_static_url([depots(:valid), users(:admin)], zoom: 100)
  end

  test "map_static_url has correct format" do
    assert_match '&format=png&', map_static_url(
                                  depots(:valid),
                                )
    assert_match '&format=png&', map_static_url(
                                  depots(:valid),
                                  maptype: GoogleMapsHelper::Type::ROADMAP
                                )
    assert_match '&format=jpg&', map_static_url(
                                  depots(:valid),
                                  maptype: GoogleMapsHelper::Type::SATELLITE
                                )
  end
end