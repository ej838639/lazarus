Lazarus
Summary
Primary Goal: Learn how to use DevOps tools and processes. 

Means to Achieve the Goal: Build a quiz-creation API. Easily turn training material into a quiz on your favorite quiz platform. Create questions from key points in training
Learning Objectives
DevOps Tools Practice
Over-build solution to learn DevOps tools. Implement multiple approaches to every stage of the pipeline to gain experience and understand pros/cons. Automate everything to make it easier to adapt the tool to use at every stage. Here are tools to explore:

Python code coverage/testing tool
CI/CD Pipeline: Jenkins, GitHub Actions
Bash scripting
Linux troubleshooting
Docker
Kubernetes
Terraform
API management
Security best practices
AWS EC2/S3/IAM/autoscaling/ECS/CloudFormation/CloudWatch
GCP Compute Engine, GKE, etc.
Monitoring: Datadog or Prometheus
Collaborate
Slack, Tweet, and Medium about ideas, gain other people interested in the project: give advice, test the solution, collaborate on building it.
High-Level Design Architecture
Provide all possible question formats, let the user delete any not desired.
No storage, no user account. Process input into quiz output.

Code Python algorithm in back-end 
Code front-end (Python Flask API to start, convert to React)
Setup PyTest to check code and automate in Jenkins
Create Docker container for Python code and React code, test interaction
Automate container builds (Jenkins, GitHub Actions)
Use Terraform to build Auto Scaling cluster with containers in AWS
Automate Terraform build in Jenkins

Later:
Divide code into APIs. 
Break up code into multiple containers with one API per container
Postgres to store previous quiz results
User account to access storage
Serverless
Project Details
Kanban

The following are initiatives, epics, stories, and tasks for the project. These are only moved to the Kanban if they are near to be implemented to avoid cluttering the Backlog.

Project Status: 
API: Basic app created as an API in Python Flask. 
Container: Docker container built and running on a GCP Compute Engine instance 
API
Create a tool to convert training material into quiz questions. Create unit tests. 

Build a DNS entry for the IP address.
Efficiencies of Tool
Create quiz questions
Suggest pictures to go with question: reduce time Google search for keywords
Format output to the quiz platform
Market Research
https://www.zoho.com/learn/focalpoint/tips-to-create-great-quizzes.html
https://samelane.com/blog/tips-create-good-elearning-quiz-questions/
https://learn.trakstar.com/blog/top-five-tips-for-creating-training-quizzes
https://www.typeform.com/quizzes/
API Architecture
FRAP model:
Flask
React
Asynchronous or Axios: Javascript library that enables asynchronous communication
Postgres

Break down into different APIs based on core function
Create all possible questions and answers from input
Select subset of questions, edit questions or answers, add images
Format question and answer to quiz tool
API Enhancements
Let use choose format for WebEx, Kahoot
ML to improve image selection
Import table: Excel, csv, md
Let user delete any questions not desired
Let user choose how to group questions into export
Non-Table Format
What are the learning objectives? Ex: know how to use Lambda
What are the key points? Ex: Create a unique name for S3 bucket
What are common mistakes? Ex: S3 bucket name already in use

Create wrong answers from common mistakes
Identify keywords to use in searching for images; search with synonyms; ML to learn images most commonly chosen per search word 
Pictures to go with question
Quiz for a Table
User input a table with 2 columns and multiple rows, API returns a quiz question in format for a quiz tool.
Topics for Quizzes
General
How to get the most out of IK
How to use Obsidian
Tab groups in Chrome

System Design

Coding General
SOLID principles
Pandas
Sorting, Recursion, Trees, Graphs, Dynamic Programming
Review MCQ for DSA section of IK

DevOps tools
Docker
Kubernetes
Tmux
Bash scripting
Linux troubleshooting
Setup Ubunutu on Mac or in Parallels
Terraform

Sorting
Selection sort strategy
Sorting method to strategy type: multiple map to same answer
Quick sort permutations: Lomuto or Hoare
Code example: identify sorting method
Time/space complexity per method: multiple map to same answer
In-place vs not-in-place per method
Stability per method
Cache friendly per method

Recursion
Match number/tree/graph/sequence to solution
Types of recursion problems: exhaustive enumeration, permutation, combination, subsets
Code example and identify problem type
Select coding approach based on problem
Example output for different types of problems: matching: {}, {a}, {b}, {c}, {ab}, … to subsets
Time/space complexity per problem type

Table Types
Create question format based on table input
Different types of tables:
List values in rows - build this first
Column has the value, and rows show Y/N for that column - build later

Example for multiple the same in column, more than one difference
Sorting Algorithm: Time complexity
Selection Sort: O($n^2$)  
Bubble Sort: O($n^2$)  
Insertion Sort: O($n^2$)  
Merge Sort: O(nlogn)  
Quick Sort: O(nlogn) 
Heap Sort: O(nlogn)

Multiple in same column, only one difference
Sorting Algorithm: Space complexity
Selection Sort: O(1)  
Bubble Sort: O(1)  
Insertion Sort: O(1)  
Merge Sort: O(n)
Quick Sort: O(1)  
Heap Sort: O(1)

Example for multiple the same in list:
In-Place
Selection Sort  
Bubble Sort  
Insertion Sort  
Quick Sort  
Heap Sort

Not In-Place
Merge Sort

Example for all different (removed some to create 1x1 mapping)
Brute Force: Bubble Sort  
Reduce and Conquer: Quick Sort  
Divide and Conquer: Merge Sort  
Transform and Conquer: Heap Sort
Algorithm for Table
Algorithm to find optimum question format.

Key:
MC1: Multiple Choice with one correct answer
MCM: Multiple choice with multiple correct answers

Table input with all different answers -> Matching
Table input with many map to same answer -> MCM From answer, select all correct questions 
Common errors -> MC1: select one correct approach

Pseudo Code for Table
Assume first column different in every row

If second column unique values: create matching question
Else
MC with col2name in the question, and Col1names in the answers
if only one is different, 
MC1 to choose the one that is not the main one and
MCM for the ones that match the most common answer (choose any if multiple common answers)

Col 1 name: Sorting Algorithm
Col 2 name: Space Complexity

What Sorting Algorithm as a Space Complexity of O(n)?
Selection Sort
Bubble Sort
Insertion Sort
Merge Sort - X
Quick Sort
Heap Sort

Choose all the Sorting Algorithms (col2name) that have Space Complexity (col2name) of O(1)?
Selection Sort - X
Bubble Sort - X
Insertion Sort - X
Merge Sort
Quick Sort - X
Heap Sort - X

Choose all the Sorting Algorithms (col2name) that have Space Complexity (col2name) of O(nlogn)? [both have 3, so choose O($n^2$) or O(nlogn)]
Selection Sort
Bubble Sort
Insertion Sort
Merge Sort - X
Quick Sort - X
Heap Sort - X

Automate Unit Testing
Run Unit Tests for every pull request. Only allow a merge if the code passes all unit tests.

Automate Containers
Automatically build a container for the API from GitHub and automatically load it in the cloud.
Epic
Automatically build container from GitHub
GitHub Actions to build a container from code commit. (Cost to use?)
https://linuxhit.com/how-to-create-docker-images-with-github-actions/

Publish container to Docker Registry
https://github.com/marketplace/actions/publish-docker

Pull container from Docker Registry, spin up a new instance, load and run container
https://containrrr.dev/watchtower/
Or write a shell script and execute with a cron job
Prepare Service to be Production Ready
Setup reverse proxy. WGSI server. HTTP server that bolsters. Options: nginx, relayd, hhaproxy, docker compose.  
Automate Testing and Deploying
Automatically upload containers into the cloud: AWS EC2 instances or GCP Compute Engine instances.
Automation environment: Run component tests (spin up one part of the tool)
E2E environment: Run end-to-end tests (interaction among parts of tool)
UAT environment: User click-through tests (any tests that cannot be automated)
Production environment: Further automate into a Kubernetes cluster.

To Do:
GCE instance overutilized message. Decide if need to follow recommendation and switch from e2-micro (2 vCPUs, 1 GB memory) to e2-small (2 vCPUs, 2 GB memory)
https://cloud.google.com/compute/vm-instance-pricing
Monitor Deployment
Create monitoring to check the health of the API.
