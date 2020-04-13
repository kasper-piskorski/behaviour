#
# Copyright (C) 2020 Grakn Labs
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

Feature: Concept Relation Type

  Background:
    Given connection has been opened
    Given connection delete all keyspaces
    Given connection does not have any keyspace
    Given connection create keyspace: grakn
    Given connection open session for keyspace: grakn
    Given session opens transaction of type: write

  Scenario: Create a new relation type with role types
    When put relation type: marriage
    When relation(marriage) set relates role: husband
    When relation(marriage) set relates role: wife
    Then relation(marriage) is null: false
    Then relation(marriage) get supertype: relation
    Then relation(marriage) get role(husband) is null: false
    Then relation(marriage) get role(wife) is null: false
    Then relation(marriage) get role(husband) get supertype: relation:role
    Then relation(marriage) get role(wife) get supertype: relation:role
    Then relation(marriage) get related roles contain:
      | husband |
      | wife    |
    When transaction commits
    When session opens transaction of type: read
    Then relation(marriage) is null: false
    Then relation(marriage) get supertype: relation
    Then relation(marriage) get role(husband) is null: false
    Then relation(marriage) get role(wife) is null: false
    Then relation(marriage) get role(husband) get supertype: relation:role
    Then relation(marriage) get role(wife) get supertype: relation:role
    Then relation(marriage) get related roles contain:
      | husband |
      | wife    |

  Scenario: Delete a relation type and its role types
    When put relation type: marriage
    When relation(marriage) set relates role: spouse
    When put relation type: parentship
    When relation(parentship) set relates role: parent
    When relation(parentship) set relates role: child
    When relation(parentship) remove related role: parent
    Then relation(parentship) get related roles do not contain:
      | parent |
    Then relation(relation) get role(role) get subtypes do not contain:
      | parentship:parent |
    When transaction commits
    When session opens transaction of type: write
    When delete relation type: parentship
    Then relation(parentship) is null: true
    Then relation(relation) get role(role) get subtypes do not contain:
      | parentship:parent |
      | parentship:child  |
    When relation(marriage) remove related role: spouse
    Then relation(marriage) get related roles do not contain:
      | spouse |
    When relation(marriage) set relates role: husband
    When relation(marriage) set relates role: wife
    When transaction commits
    When session opens transaction of type: write
    When delete relation type: marriage
    Then relation(marriage) is null: true
    Then relation(relation) get role(role) get subtypes do not contain:
      | parentship:parent |
      | parentship:child  |
      | marriage:husband  |
      | marriage:wife     |
    When transaction commits
    When session opens transaction of type: read
    Then relation(parentship) is null: true
    Then relation(marriage) is null: true
    Then relation(relation) get role(role) get subtypes do not contain:
      | parentship:parent |
      | parentship:child  |
      | marriage:husband  |
      | marriage:wife     |

  Scenario: Change the label of a relation type and its role types
    When put relation type: parentship
    When relation(parentship) set relates role: parent
    When relation(parentship) set relates role: child
    Then relation(parentship) get label: parentship
    Then relation(parentship) get role(parent) get label: parent
    Then relation(parentship) get role(child) get label: child
    When relation(parentship) set label: marriage
    When relation(marriage) get role(parent) set label: husband
    When relation(marriage) get role(child) set label: wife
    Then relation(marriage) get label: marriage
    Then relation(marriage) get role(husband) get label: husband
    Then relation(marriage) get role(wife) get label: wife
    When transaction commits
    When session opens transaction of type: write
    Then relation(marriage) get label: marriage
    Then relation(marriage) get role(husband) get label: husband
    Then relation(marriage) get role(wife) get label: wife
    When relation(marriage) set label: employment
    When relation(employment) get role(husband) set label: employee
    When relation(employment) get role(wife) set label: employer
    Then relation(employment) get label: employment
    Then relation(employment) get role(employee) get label: employee
    Then relation(employment) get role(employer) get label: employer
    When transaction commits
    When session opens transaction of type: read
    Then relation(employment) get label: employment
    Then relation(employment) get role(employee) get label: employee
    Then relation(employment) get role(employer) get label: employer