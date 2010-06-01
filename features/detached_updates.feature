@announce
Feature: Update externals and pin them to specific commits
  As a developer
  I want to update git externals and pin them to a specific commit provided in
  the config file so that my externals will match exactly when my
  giternal.yml file is updated with last_commit shas by an upstream repository.

  Scenario: Detach option passed to invalid action
    Given an external repository named 'first_external'
    When I cd to "main_repo"
    And I run "giternal status --detach"
    Then the exit status should be 1
    And I should see matching /detach option is only valid with update action/
    When I run "giternal update --detach"
    Then the exit status should be 0

  Scenario: Updating the last commit sha
    Given an external repository named 'first_external'
    When I cd to "main_repo"
    And I run "giternal update"
    And I run "giternal status --config-update"
    Then the file "config/giternal.yml" should contain the sha for "first_external" 
    When content is added to 'first_external'
    And I run "giternal update"
    Then the file "config/giternal.yml" should not contain the sha for "first_external" 
    When I run "giternal update --detach"
    Then the file "config/giternal.yml" should contain the sha for "first_external" 

  Scenario: Updating a detached repo
    Given an external repository named 'first_external'
    When I cd to "main_repo"
    And I run "giternal update"
    And I run "giternal status --config-update"
    When I run "giternal update --detach"
    Then the file "config/giternal.yml" should contain the sha for "first_external" 
    When content is added to 'first_external'
    And I run "giternal update"
    Then the file "config/giternal.yml" should not contain the sha for "first_external" 
    When I run "giternal update --detach"
    Then the file "config/giternal.yml" should contain the sha for "first_external" 

  Scenario: Getting the status detached repo
    Given an external repository named 'first_external'
    When I cd to "main_repo"
    And I run "giternal update"
    And I run "giternal status --config-update"
    Then I should not see: 
      """
      [DETACHED]
      """
    When I run "giternal update --detach"
    Then the file "config/giternal.yml" should contain the sha for "first_external" 
    When I run "giternal status"
    Then I should see matching:
      """
      .*\[DETACHED\]$
      """

