# AGENTS.md

## Project Goal

Build a DevOps assessment repository for Terraform + Database Reliability.

The assignment requires:
- Terraform AWS infrastructure design: Internet → ALB → ECS/Fargate → RDS
- Separate dev and prod Terraform environments
- Docker Compose local PostgreSQL database
- SQL migrations and seed data
- Backup and restore shell scripts
- Optional GitHub Actions Terraform plan workflow
- Clear README with verification steps

Actual AWS deployment is not required. Terraform must support:
- terraform fmt
- terraform init
- terraform validate
- terraform plan -refresh=false

## Working Rules

- Do not use real AWS secrets, passwords, access keys, or production credentials.
- Do not run terraform apply.
- Prefer realistic, production-oriented Terraform, but keep it simple enough for assessment review.
- Use PostgreSQL unless the user explicitly asks for MySQL.
- Use Docker Compose for local database testing.
- Use shell scripts that work on macOS/Linux.
- Keep the repo clean, readable, and interview-friendly.
- Explain the reason for important design choices in README.md.
- Before making large changes, show a short plan.
- After editing, run formatting/validation commands where possible.

## Required Repository Structure

Use this structure:

infra/
  modules/
    network/
    ecs/
    rds/
  envs/
    dev/
    prod/

db/
  migrations/
  seeds/

scripts/
  backup.sh
  restore.sh

.github/
  workflows/
    terraform-plan.yml

## Terraform Requirements

Create modules for:
- network
- ecs
- rds

The network module should include:
- VPC
- public subnets
- private subnets
- internet gateway
- route tables
- subnet outputs

The ecs module should include:
- ECS cluster
- Fargate task definition
- ECS service
- ALB
- target group
- listener
- security groups

The rds module should include:
- private RDS PostgreSQL
- DB subnet group
- RDS security group allowing access only from ECS security group
- backup retention variable
- deletion protection variable

Environment differences:
- dev: smaller sizing, shorter backup retention, deletion protection false
- prod: larger sizing, longer backup retention, deletion protection true

## Database Requirements

Use PostgreSQL.

Create these tables:
- hotel_bookings
- booking_events

Seed:
- at least 100 hotel bookings
- multiple cities
- multiple organizations
- multiple statuses
- booking events for some bookings

Optimize this query:

SELECT org_id, status, COUNT(*), SUM(amount)
FROM hotel_bookings
WHERE city = 'delhi'
  AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY org_id, status;

Add index/indexes and explain the choice in README.md.

## Backup and Restore Requirements

Create:
- scripts/backup.sh
- scripts/restore.sh

backup.sh should:
- create a timestamped dump
- store it under backups/

restore.sh should:
- restore from a selected/latest backup into a fresh local database
- include clear verification instructions

## README Requirements

README.md must include:
- project overview
- architecture diagram in text form
- local database setup
- migration and seed commands
- backup command
- restore command
- restore verification command
- Terraform dev commands
- Terraform prod commands
- explanation of RDS private access
- explanation of database index choice
- GitHub Actions plan workflow explanation
- final review checklist
