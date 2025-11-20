#!/usr/bin/env bash
set -euo pipefail

# bootstrap_ec2_ruby.sh
# Idempotent bootstrap for Ubuntu EC2 to install rbenv, Ruby 3.3.0, bundler/rails,
# clone the repo and run `bundle install`.
#
# Usage on the EC2 host (after SSH):
#   curl -sSL https://raw.githubusercontent.com/alyatalla/Blog-My-Life/main/deploy/bootstrap_ec2_ruby.sh | bash -s -- --repo https://github.com/alyatalla/Blog-My-Life.git
# Or if you already have the repo locally copy the file and run: ./deploy/bootstrap_ec2_ruby.sh

REPO_URL="https://github.com/alyatalla/Blog-My-Life.git"
BRANCH="main"
RUBY_VERSION="3.3.0"

print_help() {
  cat <<'EOF'
Usage: bootstrap_ec2_ruby.sh [--repo REPO_URL] [--branch BRANCH] [--ruby VERSION]

Installs system deps, rbenv, ruby, bundler, rails; clones REPO_URL and runs bundle install.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) REPO_URL="$2"; shift 2;;
    --branch) BRANCH="$2"; shift 2;;
    --ruby) RUBY_VERSION="$2"; shift 2;;
    -h|--help) print_help; exit 0;;
    --) shift; break;;
    *) echo "Unknown arg: $1"; print_help; exit 1;;
  esac
done

echo "Bootstrap starting -- repo: $REPO_URL branch: $BRANCH ruby: $RUBY_VERSION"

sudo apt update -y
sudo apt install -y --no-install-recommends \
  build-essential curl git autoconf bison pkg-config libssl-dev libreadline-dev zlib1g-dev libsqlite3-dev sqlite3 \
  libpq-dev libyaml-dev libffi-dev libgdbm-dev libncurses5-dev ca-certificates gnupg \
  nodejs npm

# Optional: install Node LTS via NodeSource for newer versions
if ! command -v node >/dev/null 2>&1; then
  echo "Installing Node LTS"
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
  sudo apt install -y nodejs
fi

if ! command -v yarn >/dev/null 2>&1; then
  echo "Installing yarn via npm"
  sudo npm install -g yarn || true
fi

# Install rbenv and ruby-build if not present
if [ ! -d "$HOME/.rbenv" ]; then
  echo "Installing rbenv & ruby-build"
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  cd ~/.rbenv && src/configure && make -C src
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
fi

# Ensure rbenv is in the PATH for the current shell
export PATH="$HOME/.rbenv/bin:$PATH"
if ! grep -q 'rbenv init' ~/.bashrc 2>/dev/null; then
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc
fi
eval "$(rbenv init -)"

# Install Ruby
if ! rbenv versions --bare | grep -q "^${RUBY_VERSION}$"; then
  echo "Installing Ruby $RUBY_VERSION (may take several minutes)"
  rbenv install "$RUBY_VERSION"
fi
echo "Setting global Ruby to $RUBY_VERSION"
rbenv global "$RUBY_VERSION"

echo "ruby -> $(ruby -v)"

# Install bundler and rails via gem (Bundler will be used by the project)
gem install bundler --no-document || true
gem install rails --no-document || true
rbenv rehash || true

echo "Bundler: $(bundle -v || true)"
echo "Rails: $(rails -v || true)"

# Clone the repo if not present
APP_DIR="$HOME/Blog-My-Life"
if [ ! -d "$APP_DIR" ]; then
  echo "Cloning $REPO_URL into $APP_DIR"
  git clone --branch "$BRANCH" "$REPO_URL" "$APP_DIR"
else
  echo "Repo already present at $APP_DIR; fetching latest"
  cd "$APP_DIR"
  git fetch origin "$BRANCH"
  git reset --hard "origin/$BRANCH"
fi

cd "$APP_DIR"

echo "Running bundle install"
bundle install --jobs 4 --retry 3 || {
  echo 'bundle install failed; inspect errors and ensure system dev libs are installed';
  exit 1
}

echo "Bootstrap finished. Next steps (choose one):"
cat <<'NEXT'
1) If you want to use SQLite for quick dev/test:
   rails db:setup
   rails db:migrate
   rails server -b 0.0.0.0 -p 3000

2) If you want PostgreSQL locally, install and create role/db (example):
   sudo apt install -y postgresql postgresql-contrib
   sudo -u postgres createuser -s $USER
   rails db:create
   rails db:migrate

3) For production-like deployment, consider using Docker (repo contains a Dockerfile). See docs or run:
   docker build -t blog-my-life:latest .
   docker run --rm --env-file /etc/blog.env -e RAILS_ENV=production blog-my-life:latest bundle exec rake db:migrate
   docker run -d --name blog -p 80:8080 --restart unless-stopped --env-file /etc/blog.env blog-my-life:latest

If you want, run one of the commands above now.
NEXT

exit 0
