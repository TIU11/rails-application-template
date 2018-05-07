# frozen_string_literal: true

# BUG:
# Abilities based on associations can't handle `nil` associations.
# @see: https://github.com/ryanb/cancan/issues/213, https://github.com/rails/rails/issues/939
#
# See the wiki for details:
# https://github.com/ryanb/cancan/wiki/Defining-Abilities
class Ability
  include CanCan::Ability

  def initialize(user, session = nil)
    @user = user
    @session = session
    @user ? user_rules : public_rules
  end

  # Rules for logged-in users
  def user_rules
    public_rules # inherits public rules

    # Update my account
    can [:read, :update], User, id: @user.id

    # Apply rules for each role
    administrator_rules if @user.is? :administrator
    # reviewer_rules if @user.is? :reviewer
    # foo_rules if @user.is? :foo
  end

  # Rules for public, un-authenticated users
  def public_rules
    can :read, :all
  end

  #
  # Role-based rules
  #

  def administrator_rules
    can :manage, :all
  end

  # def reviewer_rules
  #   can :read, :all
  # end

  # def foo_rules
  #   # foo's abilities
  # end

end
