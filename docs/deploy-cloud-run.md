# Deploying this Rails app to Google Cloud Run (GitHub → Cloud Run)

This guide creates a minimal Docker-based CI/CD flow that builds the app image on push to `main`, deploys to Cloud Run, and executes migrations as a Cloud Run Job.

Prerequisites:
- A Google Cloud project with Billing enabled.
- `gcloud` and `gcloud` APIs enabled: Cloud Run, Cloud Build, Cloud SQL Admin, Artifact Registry/Container Registry.
- A Cloud SQL Postgres instance (or any managed Postgres) and the connection name (PROJECT:REGION:INSTANCE).
- A service account with these roles: `roles/run.admin`, `roles/cloudsql.client`, `roles/cloudbuild.builds.editor` (or appropriate build/push permissions), and `roles/iam.serviceAccountUser`.

Required GitHub secrets (add in your repo Settings → Secrets):
- `GCP_PROJECT` — your Google Cloud project id
- `GCP_SA_KEY` — JSON service account key (value is whole JSON)
- `CLOUDSQL_CONNECTION_NAME` — e.g. `my-project:us-central1:my-instance`

How it works:
- GitHub Actions authenticates to GCP using `GCP_SA_KEY`.
- It runs `gcloud builds submit` to build and push the image to Container Registry.
- It deploys to Cloud Run with the Cloud SQL instance attached.
- It creates/executes a Cloud Run Job to run `rake db:migrate` against your database.

Next steps after adding the workflow:
1. Create and configure the Cloud SQL instance and database.
2. Create the GCP service account and download the JSON key; add it to `GCP_SA_KEY`.
3. Set `GCP_PROJECT` and `CLOUDSQL_CONNECTION_NAME` as repo secrets.
4. Push to `main` and watch the Actions run.

Notes and adjustments:
- If you use `importmap-rails` or hot JS toolchains, ensure `yarn`/`node` steps are adjusted in the Dockerfile.
- You may prefer Artifact Registry over Container Registry; change the image name and `gcloud` calls accordingly.
- For production `SECRET_KEY_BASE` and other env vars, use Secret Manager or GitHub secrets and set them via `--set-env-vars` or via Cloud Run service settings.
