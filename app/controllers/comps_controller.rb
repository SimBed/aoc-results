class CompsController < ApplicationController
  before_action :set_comp, only: %i[ show edit update destroy ]

  # GET /comps or /comps.json
  def index
    @comps = Comp.all.order_by_date
  end

  # GET /comps/1 or /comps/1.json
  def show
  end

  # GET /comps/new
  def new
    @comp = Comp.new
  end

  # GET /comps/1/edit
  def edit
  end

  # POST /comps or /comps.json
  def create
    @comp = Comp.new(comp_params)

    respond_to do |format|
      if @comp.save
        format.html { redirect_to comps_path, notice: "Comp was successfully created." }
        format.json { render :show, status: :created, location: @comp }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @comp.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comps/1 or /comps/1.json
  def update
    respond_to do |format|
      if @comp.update(comp_params)
        format.html { redirect_to @comp, notice: "Comp was successfully updated." }
        format.json { render :show, status: :ok, location: @comp }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @comp.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comps/1 or /comps/1.json
  def destroy
    @comp.destroy
    respond_to do |format|
      format.html { redirect_to comps_url, notice: "Comp was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comp
      @comp = Comp.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def comp_params
      params.require(:comp).permit(:date)
    end
end
