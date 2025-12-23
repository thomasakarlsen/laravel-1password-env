# 1Password Environment Secrets with Laravel Octane & Docker

A technical demonstration of how to use the **1Password CLI** to securely inject environment secrets into Docker containers running Laravel Octane with FrankenPHP.

## What This Project Demonstrates

This project showcases a production-ready approach to managing secrets in containerized Laravel applications:

- **1Password CLI Integration**: Uses Service Account tokens to fetch secrets from 1Password
- **Secure Secret Injection**: Secrets are injected at runtime via `op run`, not stored in images or `.env` files
- **Laravel Octane**: High-performance PHP application server running on FrankenPHP
- **Docker Best Practices**: Multi-stage builds, non-root user execution, proper cleanup

## Architecture

```
Docker Container
├── 1Password CLI (installed)
├── Service Account Token
└── Entrypoint Script
    ├── Reads OP_ITEM from 1Password vault
    ├── Parses JSON with jq
    └── Injects secrets via `op run --env-file`
         └── Launches Laravel Octane
```

## Prerequisites

- Docker & Docker Compose
- A 1Password account with vault access
- Service Account Token from 1Password

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/thomasakarlsen/1password-env-example.git
cd 1password-env-example
```

### 2. Set Up 1Password

1. Create a vault (or use an existing one)
2. Create an item with your secrets (can be named anything, e.g., `environment`):
   - `APP_NAME`: Laravel with 1Password
   - `APP_ENV`: Environment name (e.g., `production`)
   - `APP_DEBUG`: Debug mode (true/false)
   - `SESSION_DRIVER`: file
   - `MY_VALUE`: `SecretValueFrom1Password` (required for test verification)

3. Create a Service Account:
   - Go to **Settings** → **Developers** → **Service Accounts**
   - Create a new Service Account with access to your vault
   - Copy the generated token (starts with `ops_`)

### 3. Configure `.env.docker`

Copy the example and add your credentials:

```bash
cp .env.docker.example .env.docker
```

Edit `.env.docker`:

```dotenv
OP_SERVICE_ACCOUNT_TOKEN=ops_your_token_here
OP_ITEM=your_item_name
OP_VAULT=your_vault_name
```

### 4. Build and Run

```bash
docker compose up
```

After everything is loaded you should see the octane server running successfully, and the output of the environment test command.

### 5. Access the Application

Open your browser and navigate to: **http://localhost:8000**

You should see a welcome page with environment variables loaded from 1Password.

### 6. Verify Environment Loading

Run the test command to verify secrets are loaded:

```bash
docker compose run --rm test
```

Expected output:
```
=== Environment Variables Loaded ===
MY_VALUE: <concealed by 1Password>
APP_ENV: <concealed by 1Password>
APP_DEBUG: 1
=====================================

✓ Value is CORRECT
```

## Key Files

- **Dockerfile**: Installs 1Password CLI, Node.js, and builds the application
- **docker/entrypoint.sh**: Handles secret injection via 1Password
- **.env.docker.example**: Template showing required environment variables
- **app/Console/Commands/TestEnv.php**: Demo command to verify environment loading

## How Secrets Are Injected

1. Container starts with `OP_SERVICE_ACCOUNT_TOKEN`, `OP_ITEM`, and `OP_VAULT` environment variables
2. Entrypoint script runs:
   ```bash
   op item get "$OP_ITEM" --vault "$OP_VAULT" --format json | jq -r '.fields[] | "\(.label)=\(.reference)"'
   ```
3. Output is piped to `op run --env-file /dev/stdin -- php artisan octane:frankenphp`
4. Secrets are injected into the Laravel application runtime

## Alternative Approaches: `op run` vs Direct Injection

This demo uses **`op run`** for secret injection, which automatically redacts secret values from all output (logs, error messages, etc.). However, there's an important consideration:

### Current Approach: `op run --env-file`

**Pros:**
- Automatic redaction of secrets from all output
- Secrets never exist on disk or in shell history
- Cleaner logs without sensitive values

**Cons:**
- Laravel environments contain many common words (e.g., `connection`, `driver`, `cache`, `session`)
- 1Password CLI may accidentally redact legitimate log output containing these words
- Can make debugging difficult when common terms in error messages are concealed

### Alternative: Direct Environment Variable Injection

For applications like Laravel with large `.env` files, you might prefer direct injection:

```bash
eval "$(op item get "$OP_ITEM" --vault "$OP_VAULT" --format json | jq -r '.fields[] | "\(.label)=\(.value)"')"
exec php artisan octane:frankenphp
```

**Pros:**
- No automatic redaction means clearer logs
- Better for debugging with full error messages
- Simpler approach

**Cons:**
- Secrets appear in logs and output
- Requires more careful secret management
- Secrets are visible in process list briefly

### Alternative: Generate `.env` File

Write secrets to Laravel's `.env` file:

```bash
op item get "$OP_ITEM" --vault "$OP_VAULT" --format json | \
  jq -r '.fields[] | "\(.label)=\(.value)"' > /var/www/html/.env
exec php artisan octane:frankenphp
```

**Cons:**
- Secrets acessible as a file in running container

## License

The Laravel framework is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
