class PairsController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_action :set_pair, only: %i[ show edit update destroy ]

  # GET /pairs or /pairs.json
  def index
    case sort_column('index')

    when 'Pair'
      # @pairs = Pair.all.to_a.sort_by { |p| p.name }
      # @pairs.reverse! if sort_direction == 'desc'
      @pair_hashes = Pair.order_by_name
      @pair_hashes.reverse! if sort_direction == 'desc'
    when 'AvScore'
      # @pairs = Pair.all.to_a.sort_by { |p| -p.average_score }
      @pair_hashes = Pair.order_by_av_score
      @pair_hashes.reverse! if sort_direction == 'desc'
    when 'Played'
      # @pairs = Pair.all.to_a.sort_by { |p| -p.played }
      # @pairs.reverse! if sort_direction == 'desc'
      @pair_hashes = Pair.order_by_played
      @pair_hashes.reverse! if sort_direction == 'desc'
    end
  end

  # GET /pairs/1 or /pairs/1.json
  def show
  end

  # GET /pairs/new
  def new
    @pair = Pair.new
    # @players = Player.all.map(&:full_name)
    @players =  Player.order_by_first_name.map { |p| [p.full_name, p.id] }
  end

  # GET /pairs/1/edit
  def edit
    @players =  Player.order_by_first_name.map { |p| [p.full_name, p.id] }
  end

  # POST /pairs or /pairs.json
  def create
    @pair = Pair.new(pair_params)

    respond_to do |format|
      if @pair.save
        format.html { redirect_to pairs_path, notice: "Pair was successfully created." }
        format.json { render :show, status: :created, location: @pair }
      else
        @players =  Player.all.map { |p| [p.full_name, p.id] }
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @pair.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pairs/1 or /pairs/1.json
  def update
    respond_to do |format|
      if @pair.update(pair_params)
        format.html { redirect_to @pair, notice: "Pair was successfully updated." }
        format.json { render :show, status: :ok, location: @pair }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @pair.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pairs/1 or /pairs/1.json
  def destroy
    @pair.destroy
    respond_to do |format|
      format.html { redirect_to pairs_url, notice: "Pair was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pair
      @pair = Pair.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def pair_params
      params.require(:pair).permit(:player1_id, :player2_id)
    end

    def sort_column(view)
      # Sanitizing the search options, so only items specified in the list can get through
      case view
      when 'index'
        %w[Pair AvScore AvPos Played].include?(params[:sort]) ? params[:sort] : 'AvScore'
      when 'show'
        %w[notrelevantyet].include?(params[:sort]) ? params[:sort] : 'first_name'
      end
    end
end
