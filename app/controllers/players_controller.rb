class PlayersController < ApplicationController
  helper_method :sort_column, :sort_direction, :find_player
  before_action :set_player, only: %i[ show edit update destroy ]

  # GET /players or /players.json
  def index
    # Some columns to sort by are database table columns, some are methods.
    # The table columns can be ordered at database level. The methods require
    # the data to be extracted to a Ruby array and sorted from there.
    case sort_column('index')

    when 'first_name'
      @player_hashes = Player.order_by_firstname
      @player_hashes.reverse! if sort_direction == 'desc'
      # if Player.column_names.include?(sort_column)
      # @players = Player.order("#{sort_column('index')} #{sort_direction}")
    when 'last_name'
      @player_hashes = Player.order_by_lastname
      @player_hashes.reverse! if sort_direction == 'desc'
    when 'AvScore'
      # @players = Player.all.to_a.sort_by { |p| -p.average_score }
      # reformatted with sql in attempt to speed up
      @player_hashes = Player.order_by_av_score
      @player_hashes.reverse! if sort_direction == 'desc'
    when 'Played'
      @player_hashes = Player.order_by_played
      @player_hashes.reverse! if sort_direction == 'desc'
    end
  end

  # GET /players/1 or /players/1.json
  def show
    @partners = @player.pairs.map { |p| [@player.partner_name(p), p.id] }
    params[:pair] = @player.pairs.map { |p| p.id }.include?(params[:pair].to_i) ? params[:pair] : @player.pairs.first.id
    @pair = Pair.find(params[:pair]) || @player.pairs.first
  end

  # GET /players/new
  def new
    @player = Player.new
  end

  # GET /players/1/edit
  def edit
  end

  # POST /players or /players.json
  def create
    @player = Player.new(player_params)

    respond_to do |format|
      if @player.save
        format.html { redirect_to players_path, notice: "Player was successfully created." }
        format.json { render :show, status: :created, location: @player }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /players/1 or /players/1.json
  def update
    respond_to do |format|
      if @player.update(player_params)
        format.html { redirect_to @player, notice: "Player was successfully updated." }
        format.json { render :show, status: :ok, location: @player }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /players/1 or /players/1.json
  def destroy
    @player.destroy
    respond_to do |format|
      format.html { redirect_to players_url, notice: "Player was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_player
      @player = Player.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def player_params
      params.require(:player).permit(:first_name, :last_name)
    end

    def sort_column(view)
      # Sanitizing the search options, so only items specified in the list can get through
      case view
      when 'index'
        %w[first_name last_name AvScore AvPos Played].include?(params[:sort]) ? params[:sort] : 'AvScore'
      when 'show'
        %w[notrelevantyet].include?(params[:sort]) ? params[:sort] : 'first_name'
      end
    end

    def find_player(full_name)
      first_name = full_name.split[0]
      last_name = full_name.split[1]
      Player.find_by(first_name:first_name, last_name:last_name)
    end
end
