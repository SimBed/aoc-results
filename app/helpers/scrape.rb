require 'nokogiri'
#
class Scrape
  attr_accessor :parse_page, :results, :pairs, :players, :date

  def initialize(file, date)
    # first copy from Chrome inspector to a text file
    # 'Tues31Aug.txt', '2021-10-07'
    html = File.open(file)
    @parse_page ||= Nokogiri::HTML(html)
    @results = []
    @pairs = []
    @players = []
    @date = date
    # returns the results table data as an array of strings
    # ["1 6  Mike Christie & Barbara Cohen63.57", "251.7 / 396 18 2 21  Gaby Friedman & Ben Bor61.27",...]
    results_table_strings
    # [["Mike Christie & Barbara Cohen", 63.67], ["Gaby Friedman & Ben Bor", 61.27],...]
    results_array
    # [["Mike Christie, "Barbara Cohen"], ["Gaby Friedman", "Ben Bor"]...]
    pairs_array
    # ["Mike Christie, "Barbara Cohen","Gaby Friedman", "Ben Bor"...]
    players_array
    players_add
    pairs_add
    comp_add
    results_add
  end

  def switch_partner
    pairs.map {|p| p.reverse}
  end

  def players_add
    players.each {|p| Player.create(first_name:p.split[0],last_name:p.split[1])}
  end

  def pairs_add
    pairs.each {|p| Pair.create(player1_id: Scrape.find_player(p[0]).id, player2_id: Scrape.find_player(p[1]).id) }
  end

  def comp_add
    Comp.create(date: date)
  end

  def results_add
    results.each {|result| RelPairComp.create(pair_id: Scrape.find_pair(result[0]).id, comp_id: Scrape.find_comp(date).id, score: result[1]) }
  end

  private

    def Scrape.find_player(full_name)
      first_name = full_name.split[0]
      last_name = full_name.split[1]
      Player.find_by(first_name:first_name, last_name:last_name)
    end

    def Scrape.find_pair(full_pair_name)
      # "Mike Christie & Barbara Cohen"
      # to ["Mike Christie", "Barbara Cohen"]
      # [2, 6]
      pair = full_pair_name.split('&').map { |player| player.strip }.map { |player| Scrape.find_player(player).id }
      Pair.find_by(player1_id: pair[0], player2_id: pair[1]) || Pair.find_by(player1_id: pair[1], player2_id: pair[0])
    end

    def Scrape.find_comp(date)
      Comp.find_by(date: date)
    end

    def results_table_strings
      # using the pop method returns the last element whereas this approach returns the array without the last element
      parse_page.css("td").text.split('%')[0...-1]
    end

    def results_array
      # - allows for the double-barrelled
      regexs = /([A-Z][a-zA-Z \- \&]+)(\d+.\d+)/
      results_table_strings.each do |string|
        result = string.scan(regexs)
        # e.g. result = [["Ann Hart & Marlene Rodin", "51.42"]], an array containing all (1) match with 2 capture groups
        result[0][1].to_f
        @results << result[0]
      end
    end

    def pairs_array
      results.each do |res|
        pair = res[0].split('&').map { |player| player.strip }
        @pairs << pair
      end
    end

    def players_array
      @players = pairs.flatten
    #   pairs.each do |pair|
    #       @players << pair[0] << pair[1]
    #   end
    end
end
