class NotesController < ApplicationController
  def index
    @notes = Note.all
  end

  def show
    @notes = Note.all(params[:id])
  end

  def destroy
    #check this with Aamir
  end
end
