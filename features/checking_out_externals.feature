@announce
Feature: Checking out and updating externals
  As a developer
  I want to check out and update external projects via git
  So that I can add functionality to my app with little effort

  Scenario: Repository is not yet checked out
    Given an external repository named 'first_external'
    And 'first_external' is not yet checked out
    When I cd to "main_repo"
    And I run "giternal update"
    Then 'first_external' should be checked out

  Scenario: Multiple externals
    Given an external repository named 'first_external'
    And an external repository named 'second_external'
    When I cd to "main_repo"
    And I run "giternal update"
    Then 'first_external' should be checked out
    And 'second_external' should be checked out

  Scenario: Repository checked out then updated
    Given an external repository named 'first_external'
    When I cd to "main_repo"
    And I run "giternal update"
    And content is added to 'first_external'
    Then 'first_external' should not be up to date
    When I run "giternal update"
    Then 'first_external' should be up to date

  Scenario: Updating the last commit sha
    Given an external repository named 'first_external'
    And 'first_external' is not yet checked out
    When I cd to "main_repo"
    And I run "giternal update"
    Then the file "config/giternal.yml" should not contain "last_commit"
    When I run "giternal status --config-update"
    Then the file "config/giternal.yml" should contain "last_commit"

