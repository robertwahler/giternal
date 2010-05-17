@announce
Feature: Unfreeze externals
  As a developer
  I want to unfreeze externals
  So that I can continue to update and develop on them

  Scenario: Main project has one frozen external
    Given an external repository named 'first_external'
    When I cd to "main_repo"
    And I run "giternal update"
    And I run "giternal freeze"
    And I run "giternal unfreeze"
    Then 'first_external' should be a git repo
    And 'first_external' should be removed from the commit index
