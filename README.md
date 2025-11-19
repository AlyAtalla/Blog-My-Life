# Blog-My-Life

A small Rails-based personal blog application with users, posts, comments, likes, messaging, and a contact form. Built for local development with simple file-based image uploads and optional client-side EmailJS integration for contact delivery.

## Features

- User sign up / login (has_secure_password)
- Posts with optional images (uploaded to `public/uploads/posts/`) and public/private visibility
- Likes, Comments, and recent interactors avatar stack
- Profile pages with bio, interests and hobbies
- One-to-one messaging (inbox + per-user conversations)
- Contact form that persists messages and can send email (server SMTP or EmailJS client)
- Admin/super-user: user with email `aly@gmail.com` can edit/delete any post

## Requirements

- Ruby 3.2+ and Bundler
- SQLite (development)
- Node not required (uses classic Rails assets/importmap setup)
- PowerShell on Windows (commands below use PowerShell syntax)

## Setup (development)

1. Install Ruby and dependencies, then install gems:

```powershell
bundle install
```

2. Create and migrate the database:

```powershell
bin\rails db:create db:migrate
```

3. (Optional) Seed demo data if you have a `db/seeds.rb`:

```powershell
bin\rails db:seed
```

4. Start the server (PowerShell):

```powershell
bin\rails server
# or
bundle exec rails server
```

Open http://localhost:3000 in your browser.

## Environment variables

The app reads several environment variables to configure mail delivery and other services. On Windows you can use `setx` to persist them for your user account (restart terminal after `setx`) or set them per session with `$env:`.

- `CONTACT_RECEIVER_EMAIL` — where contact emails are delivered (default `aliatalla93@gmail.com`).

SMTP (server-side email)
- `SMTP_ADDRESS` — e.g. `smtp.gmail.com` or `smtp.mailtrap.io`
- `SMTP_PORT` — typically `587`
- `SMTP_USERNAME` — login user for SMTP
- `SMTP_PASSWORD` — SMTP password (use App Password for Gmail)

Example (PowerShell, session only):

```powershell
$env:SMTP_ADDRESS='smtp.gmail.com'
$env:SMTP_PORT='587'
$env:SMTP_USERNAME='your@gmail.com'
$env:SMTP_PASSWORD='your_app_password'
$env:CONTACT_RECEIVER_EMAIL='aliatalla93@gmail.com'
bin\rails server
```

### EmailJS (client-side mail)

The contact form supports EmailJS so you can send contact messages from the browser without configuring SMTP locally.

- Sign up at https://www.emailjs.com
- Create a Service and an Email Template
- The project already includes the EmailJS `service` id set to `service_0og5zvn` (replace if you want another service).
- Set the EmailJS public id (formerly "user id") and template id into the contact form dataset values or environment if you prefer.

To enable EmailJS client-side sending, update the contact form partial `app/views/contact_messages/_form.html.erb` data attributes:

```erb
html: { id: 'contact-form', data: { emailjs_service: 'service_0og5zvn', emailjs_template: 'template_XXXX', emailjs_public_id: 'your_public_key' } }
```

When EmailJS is configured in the frontend, the form will use `emailjs.sendForm` and also POST the message to the server to persist a copy.

## File uploads (post images)

- Uploaded images are saved to `public/uploads/posts/` with a filename `post_<id>_<timestamp>.<ext>` and the `image_url` on the Post is set accordingly.
- This is intended for development; for production use Active Storage + S3 or another hosted solution.

## Admin / Super-user

- The app treats the user with email `aly@gmail.com` as a super-user who may edit and delete any post.
- You can change this behavior in `app/controllers/posts_controller.rb` (search for `aly@gmail.com`).

## Notes on responsiveness

- Global responsive CSS live in `app/views/layouts/application.html.erb` (small project-style overrides). Images and card sizes adjust for tablet and mobile breakpoints.
- Use DevTools device emulation to validate the layout.

## VS Code workspace settings

- The workspace disables VS Code audio cues. See `.vscode/settings.json`.

## Troubleshooting

- If you see `ActiveRecord::PendingMigrationError`, run migrations with:

```powershell
bin\rails db:migrate
```

- To debug email delivery, check `log/development.log` or run the runner test:

```powershell
bin\rails runner "cm = ContactMessage.new(name: 'Test', email: 'you@example.com', message: 'Hello test'); ContactMailer.notify(cm).deliver_now; puts 'sent'"
```

## Development tips

- For quick previews of email instead of sending real mail, install `letter_opener` gem and Rails will open messages in the browser (the project already attempts to use it if available).
- Consider switching file uploads to Active Storage before deploying to a production environment.

## Contributing

- Create feature branches and open PRs. Keep changes small and focused.

If you'd like, I can also:
- Patch `README.md` to include more step-by-step screenshots or a quick-start script.
- Add a small `.env.example` and integrate `dotenv-rails` to manage local env vars more comfortably.

---
Happy hacking — tell me if you'd like any of the optional improvements wired in automatically.
