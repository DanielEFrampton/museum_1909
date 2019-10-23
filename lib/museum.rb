class Museum
  attr_reader :name, :exhibits, :patrons, :revenue, :patrons_of_exhibits

  def initialize(name)
    @name = name
    @exhibits = []
    @patrons = []
    @revenue = 0
    @patrons_of_exhibits = Hash.new { |hash, key| hash[key] = [] }
  end

  def add_exhibit(exhibit)
    @exhibits << exhibit
  end

  def admit(patron)
    @patrons << patron
    attend_exhibits(patron)
  end

  def attend_exhibits(patron)
    interested_exhibits_by_cost(patron).each do |exhibit|
      if can_afford?(patron, exhibit)
        pay_museum(patron, exhibit)
        record_attendance(patron, exhibit)
      end
    end
  end

  def pay_museum(patron, exhibit)
    @revenue += exhibit.cost
    patron.spending_money -= exhibit.cost
  end

  def record_attendance(patron, exhibit)
    @patrons_of_exhibits[exhibit] << patron
  end

  def can_afford?(patron, exhibit)
    patron.spending_money >= exhibit.cost
  end

  def interested_exhibits_by_cost(patron)
    recommend_exhibits(patron).sort do |exhibit1, exhibit2|
      exhibit2.cost <=> exhibit1.cost
    end
  end

  def recommend_exhibits(patron)
    @exhibits.select do |exhibit|
      interested?(patron, exhibit)
    end
  end

  def patrons_by_exhibit_interest
    @exhibits.reduce({}) do |hash, exhibit|
      if !patrons_who_like_exhibit(exhibit).empty?
        hash[exhibit] = patrons_who_like_exhibit(exhibit)
      end
      hash
    end
  end

  def patrons_who_like_exhibit(exhibit)
    @patrons.select do |patron|
      interested?(patron, exhibit)
    end
  end

  def interested?(patron, exhibit)
    patron.interests.include?(exhibit.name)
  end
end
