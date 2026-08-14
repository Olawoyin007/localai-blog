+++
title = "Run your first model, step by step"
date = 2026-07-05
weight = 5
authorship = "human-ai"
+++

Here is a small promise: on the computer you already own, you will soon be talking to an AI that runs entirely on your own machine. No account. No internet, once it is set up. Nothing you type goes anywhere.

How long it takes is mostly down to one thing: your internet. The setup is a few minutes of clicking. The model itself is about a gigabyte to download, which might be two minutes on fast fibre or twenty on a slow line. The *work* is quick; the waiting is just your download. So no false "ten minutes" promise here, it depends on your connection.

Most people think this needs a special setup. It does not. Let's just do it, and you can feel the "wow" for yourself.

## What you need

- A normal laptop or desktop (Mac, Windows, or Linux).
- About 3GB of free disk space for the little model we'll download.
- A few minutes of setup, plus the download (which depends on your internet speed).

You do **not** need a fancy graphics card. We are using a tiny model on purpose, and it runs happily on ordinary machines. (More on why in [do you even need a GPU]({{< relref "do-you-need-a-gpu" >}}).)

## Step 1 - Install Ollama

Ollama is a free program that makes running local models as simple as one command.

- **Mac or Windows:** go to [ollama.com/download](https://ollama.com/download) and install it like any other app.
- **Linux:** open a terminal and run:

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

**Check it worked.** In a terminal, type:

```bash
ollama --version
```

You should see something like:

```
ollama version is 0.6.2
```

If you see a version number, you are ready. That is the check.

## Step 2 - Run your first model

One command downloads a small model and starts it. We'll use `llama3.2:1b` - a 1-billion model, small and quick, perfect for a first run:

```bash
ollama run llama3.2:1b
```

The first time, it downloads the model (this is the only part that needs internet). You'll see a progress bar:

```
pulling manifest
pulling 74701a8c35f6... 100% ▕████████████████▏ 1.3 GB
verifying sha256 digest
writing manifest
success
>>>
```

When the download finishes, you land at a `>>>` prompt. That prompt is the model, waiting for you.

## Step 3 - Talk to it

Type a question and press Enter. For example:

```
>>> in one sentence, what is a local model?
```

And it answers, right there on your machine:

```
A local model is an AI that runs on your own computer instead of on a
company's servers, so your data stays with you and works even offline.
```

That is it. That answer was written by an AI running on *your* computer. Nothing was sent to the cloud. Turn off your wifi and ask it again - it still works.

## Step 4 - Leave, and come back

To stop chatting, type:

```
>>> /bye
```

The model is still installed. You can see it, and any others, with:

```bash
ollama list
```

```
NAME           ID            SIZE     MODIFIED
llama3.2:1b    baf6a787fdff  1.3 GB   2 minutes ago
```

Next time, `ollama run llama3.2:1b` starts instantly - no download, no internet needed.

## If something looks wrong

A few things that trip people up, and what each one actually means:

- **`command not found: ollama`** - the install did not finish, or the terminal needs reopening. Close it, open a fresh one, and try again. On Mac or Windows, make sure the Ollama app is actually open.
- **`Error: could not connect to ollama` (or "connection refused")** - the Ollama program is not running in the background. On Mac/Windows, open the Ollama app. On Linux, run `ollama serve` in another terminal.
- **The download is crawling** - that is your internet, not a fault. A model is a big file. Leave it running; if the connection drops, it picks up where it left off.
- **It runs, but painfully slowly, or the machine freezes** - the model is too big for your memory. Stop it (`/bye`) and use a smaller one. `llama3.2:1b` is about as light as it gets.

**What "working" looks like**, so you know you are on track: `ollama --version` prints a version; the download bar reaches 100% and says `success`; and you land on the `>>>` prompt. See those, and nothing is wrong, it is just downloading or thinking.

## Wait... did I just run an AI?

Yes. You did.

No sign-up, no subscription, nothing leaving your machine. A real language model, living on your own machine, answering you. If it felt too easy, that is the point - the hard part was always the myth that you needed special hardware or deep knowledge. You needed one program and one command.

From here you can try a slightly bigger, smarter model the same way (`ollama run llama3.2:3b`), or read [what a local LLM actually is]({{< relref "what-is-a-local-llm" >}}) now that you have one running. But take a second first. You just ran an AI on your own computer. Wow, indeed.
