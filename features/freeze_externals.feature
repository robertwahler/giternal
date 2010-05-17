@announce
Feature: Freeze externals
  As a developer
  I want to freeze externals
  So that I can test and deploy my app with no worries

  Scenario: Main project has one external
    Given an external repository named 'first_external'
    When I cd to "main_repo"
    And I run "giternal update"
    And I run "giternal freeze"
    Then 'first_external' should no longer be a git repo
    And 'first_external' should be added to the commit index

  Scenario: External has been added to .gitignore
    Given an external repository named 'first_external'
    And the external 'first_external' has been added to .gitignore
    And I cd to "main_repo"
    And I run "giternal update"
    When I run "giternal freeze"
    Then 'first_external' should be added to the commit index

