# Task Management SQL Project

## Project Description
A SQL Server-based system for managing organizational tasks. The system supports user management, task assignment, status tracking, task hierarchy, and reporting for both employees and managers.

## File Structure
- **Part A - Data.sql**  
  Database creation, table definitions, and initial data population.
- **Part B - Objects.sql**  
  Creation of functions, procedures, triggers, and other database objects.
- **Part C - Executions.sql**  
  Example executions of functions and procedures, including test cases and usage scripts.

## Main Tables
- `Users` — System users, including manager hierarchy.
- `Task` — Tasks, with fields for creator, assignee, status, and parent task (for hierarchical tasks).
- `TaskStatus` — Possible statuses for tasks.

## Key Functions and Procedures
- `isValueUser` — Validates username and password.
- `UnderEmployees` — Returns all employees under a specific manager (recursive).
- `taskUnder` — Returns all sub-tasks under a specific task (recursive).
- `parentTask` — Returns the parent chain of a task.
- `changeStatus` — Changes the status of a task.
- `addTask` — Adds a new task.
- `addGeneralTasks` — Adds a general task for all employees under a manager.
- `partitionByStatus` — Generates a status-based task report.
- `tasksForUser` — Returns all tasks for a user by username and password.

## Setup and Usage
1. Run the files in the following order:
   1. `Part A - Data.sql` — Database and initial data setup.
   2. `Part B - Objects.sql` — Functions, procedures, and triggers.
   3. `Part C - Executions.sql` — Example queries and tests.

2. Make sure to execute on a compatible SQL Server instance.

## Notes
- All code is written in T-SQL.
- Run the scripts in order to avoid dependency errors.
- The system can be extended by adding more tables, procedures, or functions as needed.

---
