# Local AI, Simply

A calm, quiet blog about running AI on your own machine. Built with
[Hugo](https://gohugo.io) as a **static site** - plain HTML files, no database, no
login, nothing running on the server except the web server handing out files.

- **You write** on your own machine, in plain Markdown.
- **Git** is your save button, your history, and your backup.
- **The rules that keep it calm live in [PRINCIPLES.md](PRINCIPLES.md)** - read that first.

---

## Write a post (the easy way)

```bash
./new-post.sh beginner "How to pick your first model"
```

That makes `content/beginner/how-to-pick-your-first-model.md`, with the date filled
in, tagged `organic`, and marked as a draft. Open it, write, and when it's ready
**delete the `draft = true` line**. That's the whole workflow.

Sections you can use: `beginner`, `advanced`, `wellbeing`.

### The top of every post (front matter)

```
+++
title = "How to pick your first model"
date = 2026-07-30
authorship = "organic"
+++
```

`authorship` is the little sticker. Two choices only:

| value      | sticker      | meaning                     |
|------------|--------------|-----------------------------|
| `organic`  | Organic      | written entirely by you     |
| `human-ai` | Human + AI   | written with AI help        |

### Code blocks - just fence them

Put three backticks and the language, and it colours itself. Nothing else to do:

    ```bash
    ollama run qwen3.5
    ```

### Images

Drop the image in the same folder as the post and link it: `![](diagram.png)`.
(For a post with its own files, make a folder with an `index.md` inside - see
`content/advanced/how-a-local-model-answers/` if you kept it.)

### Videos (link to YouTube)

Videos live on your YouTube channel - short and quiet, no background music. In a post,
just link to them:

```
[Watch: your first local model (3 min)](https://youtu.be/your-video-id)
```

A plain link is safe - it does not track your readers. Never paste YouTube's **embed**
iframe, which loads Google's trackers onto your page before anyone even presses play.

---

## Preview while you write

```bash
hugo server -D
```

Open <http://localhost:1313>. It reloads as you type. `-D` shows drafts so you can
see work in progress. (If `hugo` isn't found, use the full path `~/.local/bin/hugo`.)

---

## Publish it

1. Build the finished site:
   ```bash
   hugo
   ```
   This writes everything into `public/` (drafts are left out automatically).

2. Copy it to your server (replace with your real host + path):
   ```bash
   rsync -az --delete public/ deploy@YOUR-SERVER:/srv/localai-blog/
   ```

3. On the server, Caddy just serves the folder:
   ```
   blog.yourdomain.com {
       encode zstd gzip
       root * /srv/localai-blog
       file_server
   }
   ```

Then save your work: `git add -A && git commit -m "New post" && git push`.
(`public/` is git-ignored on purpose - git tracks your writing, rsync ships the built HTML.)

---

## What each thing is (so nothing is a mystery)

```
content/            your writing (one .md file per post)
  beginner/  advanced/  wellbeing/   the three sections
  about.md          your About page
  search.md         the search page (empty - it just triggers the layout)
layouts/            the HTML templates (all commented)
  _default/         baseof (page shell), single (a post), list (a section), search
  partials/         head, header (nav), authorship (sticker), disclaimer, pager
  index.html        the homepage
  index.json        builds the search index (auto - don't edit)
static/
  css/style.css     the one stylesheet (colours + fonts at the top)
  favicon.svg       the tab icon
archetypes/default.md   the template new posts are made from
new-post.sh         the helper above
hugo.toml           settings (site title, your name, colours theme, etc.)
PRINCIPLES.md       what this site must never become - the guardrail
```

---

## First-time setup on a new machine

Install Hugo (one binary): `sudo apt install hugo`, or grab the latest from
<https://github.com/gohugoio/hugo/releases>. Nothing else is needed to write or preview.

## Later: more languages

Hugo has this built in. When you're ready, uncomment the `[languages]` block in
`hugo.toml` and add posts under `content/fr/`, `content/es/`, etc. English works on
its own until then.
