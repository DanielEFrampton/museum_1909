class Museum
  attr_reader :name, :exhibits, :patrons

  def initialize(name)
    @name = name
    @exhibits = []
    @patrons = []
  end

  def add_exhibit(exhibit)
    @exhibits << exhibit
  end

  def admit(patron)
    @patrons << patron
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
