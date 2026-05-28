class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:upgrade]

  def landing
  end

  def pricing
  end

  def upgrade
    if current_user.pro?
      redirect_to articles_path, notice: "You're already on the Pro plan."
      return
    end

    # In production, this would go through Stripe checkout.
    # For now, we upgrade directly (simulating successful payment).
    current_user.upgrade_to_pro!
    redirect_to articles_path, notice: "Upgraded to Pro! You now have 200 generations per month."
  end
end
