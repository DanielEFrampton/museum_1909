require 'minitest/autorun'
require 'minitest/pride'
require './lib/patron'
require './lib/exhibit'
require './lib/museum'

class MuseumTest < Minitest::Test

  def setup
    @dmns = Museum.new("Denver Museum of Nature and Science")
    @gems_and_minerals = Exhibit.new("Gems and Minerals", 0)
    @dead_sea_scrolls = Exhibit.new("Dead Sea Scrolls", 10)
    @imax = Exhibit.new("IMAX", 15)
    @bob = Patron.new("Bob", 10)
    @sally = Patron.new("Sally", 20)
    @tj = Patron.new("TJ", 7)
    @morgan = Patron.new("Morgan", 15)
  end

  def test_it_exists
    assert_instance_of Museum, @dmns
  end

  def test_it_initializes_with_attributes
    assert_equal "Denver Museum of Nature and Science", @dmns.name
    assert_equal [], @dmns.exhibits
    assert_equal [], @dmns.patrons
    assert_equal 0, @dmns.revenue
    empty_hash = {}
    assert_equal empty_hash, @dmns.patrons_of_exhibits
  end

  def test_it_can_add_exhibits
    @dmns.add_exhibit(@gems_and_minerals)
    @dmns.add_exhibit(@dead_sea_scrolls)
    @dmns.add_exhibit(@imax)
    assert_equal [@gems_and_minerals, @dead_sea_scrolls, @imax], @dmns.exhibits
  end

  def test_it_can_recommend_exhibits_for_given_patron
    @dmns.add_exhibit(@gems_and_minerals)
    @dmns.add_exhibit(@dead_sea_scrolls)
    @dmns.add_exhibit(@imax)
    @bob.add_interest("Dead Sea Scrolls")
    @bob.add_interest("Gems and Minerals")
    @sally.add_interest("IMAX")
    assert_equal [@gems_and_minerals, @dead_sea_scrolls], @dmns.recommend_exhibits(@bob)
    assert_equal [@imax], @dmns.recommend_exhibits(@sally)
  end

  def test_it_can_admit_patrons
    @dmns.admit(@bob)
    @dmns.admit(@sally)
    assert_equal [@bob, @sally], @dmns.patrons
  end

  def test_it_can_tell_if_patron_interested_in_given_exhibit
    @dmns.add_exhibit(@gems_and_minerals)
    @dmns.add_exhibit(@dead_sea_scrolls)
    @dmns.add_exhibit(@imax)
    @dmns.admit(@bob)
    @dmns.admit(@sally)
    @bob.add_interest("Dead Sea Scrolls")
    @bob.add_interest("Gems and Minerals")
    @sally.add_interest("Dead Sea Scrolls")
    assert_equal true, @dmns.interested?(@bob, @gems_and_minerals)
    assert_equal false, @dmns.interested?(@sally, @gems_and_minerals)
    assert_equal true, @dmns.interested?(@bob, @dead_sea_scrolls)
    assert_equal true, @dmns.interested?(@sally, @dead_sea_scrolls)
  end

  def test_it_can_find_all_patrons_who_like_exhibit
    @dmns.add_exhibit(@gems_and_minerals)
    @dmns.add_exhibit(@dead_sea_scrolls)
    @dmns.add_exhibit(@imax)
    @dmns.admit(@bob)
    @dmns.admit(@sally)
    @bob.add_interest("Dead Sea Scrolls")
    @bob.add_interest("Gems and Minerals")
    @sally.add_interest("Dead Sea Scrolls")
    assert_equal [@bob, @sally], @dmns.patrons_who_like_exhibit(@dead_sea_scrolls)
    assert_equal [@bob], @dmns.patrons_who_like_exhibit(@gems_and_minerals)
  end

  def test_it_can_find_patrons_by_exhibit_interests
    @dmns.add_exhibit(@gems_and_minerals)
    @dmns.add_exhibit(@dead_sea_scrolls)
    @dmns.add_exhibit(@imax)
    @dmns.admit(@bob)
    @dmns.admit(@sally)
    @bob.add_interest("Dead Sea Scrolls")
    @bob.add_interest("Gems and Minerals")
    @sally.add_interest("Dead Sea Scrolls")
    expected_hash = {
                      @gems_and_minerals => [@bob],
                      @dead_sea_scrolls => [@bob, @sally]
                    }
    assert_equal expected_hash, @dmns.patrons_by_exhibit_interest
  end

  def test_it_can_sort_interested_exhibits_from_costliest_to_cheapest
    @dmns.add_exhibit(@gems_and_minerals)
    @dmns.add_exhibit(@dead_sea_scrolls)
    @dmns.add_exhibit(@imax)
    @bob.add_interest("Dead Sea Scrolls")
    @bob.add_interest("IMAX")
    assert_equal [@imax, @dead_sea_scrolls], @dmns.interested_exhibits_by_cost(@bob)
    @morgan.add_interest("Gems and Minerals")
    @morgan.add_interest("Dead Sea Scrolls")
    assert_equal [@dead_sea_scrolls, @gems_and_minerals], @dmns.interested_exhibits_by_cost(@morgan)
  end

  def test_its_patrons_attend_exhibits_from_most_to_least_expensive
    @dmns.add_exhibit(@gems_and_minerals)
    @dmns.add_exhibit(@dead_sea_scrolls)
    @dmns.add_exhibit(@imax)
    @tj.add_interest("IMAX")
    @tj.add_interest("Dead Sea Scrolls")
    @dmns.admit(@tj)
    assert_equal 7, @tj.spending_money
    @bob.add_interest("Dead Sea Scrolls")
    @bob.add_interest("IMAX")
    @dmns.admit(@bob)
    assert_equal 0, @bob.spending_money
    @sally.add_interest("IMAX")
    @sally.add_interest("Dead Sea Scrolls")
    @dmns.admit(@sally)
    assert_equal 5, @sally.spending_money
    @morgan.add_interest("Gems and Minerals")
    @morgan.add_interest("Dead Sea Scrolls")
    @dmns.admit(@morgan)
    assert_equal 5, @morgan.spending_money
  end

  def test_it_can_record_patron_attendance
    @dmns.add_exhibit(@gems_and_minerals)
    @dmns.add_exhibit(@dead_sea_scrolls)
    @dmns.add_exhibit(@imax)
    @tj.add_interest("IMAX")
    @tj.add_interest("Dead Sea Scrolls")
    @dmns.admit(@tj)
    empty_hash = {}
    assert_equal empty_hash, @dmns.patrons_of_exhibits
    @bob.add_interest("Dead Sea Scrolls")
    @bob.add_interest("IMAX")
    @dmns.admit(@bob)
    attendance_hash_1 = {
                          @dead_sea_scrolls => [@bob]
                        }
    assert_equal attendance_hash_1, @dmns.patrons_of_exhibits
    @sally.add_interest("IMAX")
    @sally.add_interest("Dead Sea Scrolls")
    @dmns.admit(@sally)
    attendance_hash_2 = {
                          @dead_sea_scrolls => [@bob],
                          @imax => [@sally]
                        }
    assert_equal attendance_hash_2, @dmns.patrons_of_exhibits
    @morgan.add_interest("Gems and Minerals")
    @morgan.add_interest("Dead Sea Scrolls")
    @dmns.admit(@morgan)
    attendance_hash_3 = {
                          @dead_sea_scrolls => [@bob, @morgan],
                          @imax => [@sally],
                          @gems_and_minerals => [@morgan]
                        }
    assert_equal attendance_hash_3, @dmns.patrons_of_exhibits
  end

  def test_it_tracks_revenue_from_exhibit_attendance
    @dmns.add_exhibit(@gems_and_minerals)
    @dmns.add_exhibit(@dead_sea_scrolls)
    @dmns.add_exhibit(@imax)
    @tj.add_interest("IMAX")
    @tj.add_interest("Dead Sea Scrolls")
    @dmns.admit(@tj)
    assert_equal 0, @dmns.revenue
    @bob.add_interest("Dead Sea Scrolls")
    @bob.add_interest("IMAX")
    @dmns.admit(@bob)
    assert_equal 10, @dmns.revenue
    @sally.add_interest("IMAX")
    @sally.add_interest("Dead Sea Scrolls")
    @dmns.admit(@sally)
    assert_equal 25, @dmns.revenue
    @morgan.add_interest("Gems and Minerals")
    @morgan.add_interest("Dead Sea Scrolls")
    @dmns.admit(@morgan)
    assert_equal 35, @dmns.revenue
  end
end
