class QueriesController < ApplicationController
  protect_from_forgery :except => [:create]
  
  def create
    query_string = params[:query]
    query_variables = ensure_hash(params[:variables])
    result = Schema.execute(query_string, variables: query_variables)
    render json: result
  end


  private

  def ensure_hash(query_variables)
    if query_variables.blank?
      {}
    elsif query_variables.is_a?(String)
      JSON.parse(query_variables)
    else
      query_variables
    end
  end
end
