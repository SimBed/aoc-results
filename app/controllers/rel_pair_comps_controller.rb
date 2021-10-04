class RelPairCompsController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_action :set_rel_pair_comp, only: %i[ show edit update destroy ]

  # GET /rel_pair_comps or /rel_pair_comps.json
  def index
    case sort_column('index')

    when 'Pair'
      @rel_pair_comps = RelPairComp.all.to_a.sort_by { |rel| Pair.find(rel.pair_id).name }
      @rel_pair_comps.reverse! if sort_direction == 'desc'
    when 'Comp'
      @rel_pair_comps = RelPairComp.all.to_a.sort_by { |rel| Comp.find(rel.comp_id).date }
      @rel_pair_comps.reverse! if sort_direction == 'desc'
      # @matches = @player.matches.to_a.sort_by { |m| @player.send(sort_column('show'), m) }
    when 'Score'
      @rel_pair_comps = RelPairComp.all.to_a.sort_by { |rel| -rel.score }
      @rel_pair_comps.reverse! if sort_direction == 'desc'
    when 'Position'
      @rel_pair_comps = RelPairComp.all.to_a.sort_by { |rel| -rel.position }
      @rel_pair_comps.reverse! if sort_direction == 'desc'
    end
  end

  # GET /rel_pair_comps/1 or /rel_pair_comps/1.json
  def show
  end

  # GET /rel_pair_comps/new
  def new
    @rel_pair_comp = RelPairComp.new
    @pairs =  Pair.all.to_a.sort_by { |p| p.name }.map { |p| [p.name, p.id] }
    @comps = Comp.order_by_date.map { |c| [c.formatted_date, c.id] }
  end

  # GET /rel_pair_comps/1/edit
  def edit
    @pairs =  Pair.all.to_a.sort_by { |p| p.name }.map { |p| [p.name, p.id] }
    @comps = Comp.order_by_date.map { |c| [c.formatted_date, c.id] }
  end

  # POST /rel_pair_comps or /rel_pair_comps.json
  def create
    @rel_pair_comp = RelPairComp.new(rel_pair_comp_params)

    respond_to do |format|
      if @rel_pair_comp.save
        format.html { redirect_to rel_pair_comps_path, notice: "Result was successfully created." }
        format.json { render :show, status: :created, location: @rel_pair_comp }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @rel_pair_comp.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rel_pair_comps/1 or /rel_pair_comps/1.json
  def update
    respond_to do |format|
      if @rel_pair_comp.update(rel_pair_comp_params)
        format.html { redirect_to @rel_pair_comp, notice: "Result was successfully updated." }
        format.json { render :show, status: :ok, location: @rel_pair_comp }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @rel_pair_comp.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rel_pair_comps/1 or /rel_pair_comps/1.json
  def destroy
    @rel_pair_comp.destroy
    respond_to do |format|
      format.html { redirect_to rel_pair_comps_url, notice: "Result was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rel_pair_comp
      @rel_pair_comp = RelPairComp.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def rel_pair_comp_params
      params.require(:rel_pair_comp).permit(:pair_id, :comp_id, :score, :position)
    end

    def sort_column(view)
      # Sanitizing the search options, so only items specified in the list can get through
      case view
      when 'index'
        %w[Pair Comp Score Position].include?(params[:sort]) ? params[:sort] : 'Pair'
      when 'show'
        %w[notrelevantyet].include?(params[:sort]) ? params[:sort] : 'first_name'
      end
    end
end
