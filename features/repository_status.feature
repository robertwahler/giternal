@announce
Feature: Show status of each repo

  Scenario: Updated repo
    Given an external repository named 'first_external'
    When I cd to "main_repo"
    And I run "giternal status"
    Then I should not see "Last commit"
    And I should see "run update first"
    And I run "giternal update"
    And I run "giternal status"
    Then I should see "is clean"
    And I should see "Last commit"

  Scenario: Frozen repo
    Given an external repository named 'first_external'
    When I cd to "main_repo"
    And I run "giternal update"
    And I run "giternal freeze"
    And I run "giternal status"
    Then I should see "is frozen"



