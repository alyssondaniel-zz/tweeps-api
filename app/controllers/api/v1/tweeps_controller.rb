class Api::V1::TweepsController < ApplicationController
  before_action :set_tweeps, only: [:most_relevants, :most_mentions]

  def most_relevants
    tweeps = @tweeps.map{|t| ClientTweep::TweepResource.from_json(t) }
    json_response(tweeps)
  end

  def most_mentions
    most_mentions = @clientTweep.most_mentions(@tweeps)
    tweeps = most_mentions.map{|t| ClientTweep::UserResource.from_json(t) }
    json_response(tweeps)
  end

  private
  def set_tweeps
    @clientTweep = ClientTweep::Api.new
    all = @clientTweep.getAll({q: "@locaweb"})

    most_relevants = @clientTweep.most_relevants(all)
    @tweeps = @clientTweep.by_order(most_relevants)
  end
end
