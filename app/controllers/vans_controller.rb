class VansController < ApplicationController
  def create
    van = Van.create( van_params )
    if van.save
      redirect_to action: :index
    else
      flash[ :error ] = 'Could not create van.'
      redirect_to action: :new
    end
  end

  def edit
    @van = Van.find params[ :id ]
  end

  def destroy
    if Van.find( params[ :id ] ).destroy
      flash[ :notice ] = 'Van destroyed.'
    else
      flash[ :error ] = 'Could not destroy van.'
    end
    redirect_to :back
  end

  def index
    @vans = Van.all.order :id
  end

  def new
    @van = Van.new
  end

  def update
    van = Van.find params[ :id ]
    if van.update van_params
      redirect_to action: :index
    else
      flash[ :error ] = 'Could not update van.'
      redirect_to [ :edit, van ]
    end
  end

  private

  def process_tags( par )
    par[ :tags ] = par[ :tags ].split( ',' ).map( &:strip ) if par.key? :tags
    par
  end

  def van_params
    process_tags params.require( :van ).permit( :make, :model, :tags )
  end
end

