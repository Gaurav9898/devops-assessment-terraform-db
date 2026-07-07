---
name: devops-assessment
description: Use this skill for building or reviewing a Terraform and database reliability assessment repository with AWS VPC, ALB, ECS/Fargate, private RDS PostgreSQL, Docker Compose PostgreSQL, migrations, seed data, backup/restore scripts, GitHub Actions Terraform plan checks, and README verification steps.
---

# DevOps Assessment

## Workflow

Use this skill when the task is to create, finish, or review the DevOps assessment repository.

1. Inspect the repository before editing.
2. Keep the required structure: `infra/`, `db/`, `scripts/`, `.github/workflows/`, and this `.agents/skills/devops-assessment/` skill.
3. Do not commit real AWS credentials, database secrets, access keys, or production values.
4. Do not run `terraform apply`.
5. Prefer PostgreSQL unless the user explicitly asks for MySQL.
6. Make Terraform realistic but plan-only friendly.
7. Run safe validation commands when possible and report anything that could not be run.

## Required Build

Terraform:
- `infra/modules/network`: VPC, public/private subnets, internet gateway, route tables, subnet outputs.
- `infra/modules/ecs`: ALB, ALB security group, ECS security group, ECS cluster, Fargate task definition, service, target group, listener.
- `infra/modules/rds`: private PostgreSQL RDS, DB subnet group, RDS security group that allows PostgreSQL only from ECS, backup retention and deletion protection variables.
- `infra/envs/dev` and `infra/envs/prod`: separate variables, tfvars examples, backend config, sizing, backup retention, and deletion protection.

Database:
- Docker Compose PostgreSQL container named `hotel_postgres`.
- Database `hotel_db`, user `hotel_user`, local-only password `hotel_password`.
- Tables `hotel_bookings` and `booking_events`.
- Seed at least 100 bookings across multiple cities, organizations, and statuses.
- Add an index for the assessment query:
  `hotel_bookings (city, created_at, org_id, status)`.

Scripts:
- `scripts/backup.sh` creates timestamped dumps under `backups/`.
- `scripts/restore.sh` restores a selected or latest dump into a fresh local restore database.

Documentation:
- README must include setup, verification, Terraform commands, backup/restore commands, RDS private access explanation, index explanation, GitHub Actions explanation, and final checklist.
