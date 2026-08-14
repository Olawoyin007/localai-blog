+++
title = "Run a model on your phone"
date = 2026-06-14
weight = 7
authorship = "human-ai"
+++

The same small promise as running one on a laptop, but smaller and stranger: the phone in your pocket can run its own AI. No account, no internet once it's downloaded, nothing sent anywhere. In a few minutes, and a few taps.

If running a model on a computer felt surprising, running one on a phone feels almost silly. Let's do it.

## What you need

- A reasonably recent phone (iPhone or Android).
- About 2GB of free space for a small model.
- Wifi for the one-time download. How long it takes is down to your wifi speed, not the app, so there's no honest "few minutes" promise here.

## Step 1 - Install a local AI app

We'll use **PocketPal AI**. It is free, open-source, and does the whole thing on your phone with no account.

Open your app store and search for **PocketPal AI**:

- **iPhone:** the App Store.
- **Android:** Google Play.

Install it like any other app.

## Step 2 - Download a small model

Open the app and go to its list of models (usually a "Models" or "Hub" screen). You'll see a menu of models you can download.

Pick a **small** one, around 1 to 2 billion (you'll see sizes like **1B** or **2B**). Good first choices are names like **Gemma 3 1B**, **Qwen 3 1.7B**, or **Phi-4 mini**. Tap to download.

This is the only step that needs wifi. It downloads once (a gigabyte or two) and then lives on your phone.

## Step 3 - Load it and chat

When the download finishes, tap the model to load it, then open a new chat. You'll get a familiar chat box. Type something:

```
You:  in one sentence, why would I run AI on my phone?

AI:   So it works anywhere, keeps your conversations private on your
      own device, and never needs an account or a signal.
```

That reply was written by a model running on your phone. Not in a data centre. In your hand.

## The check that proves it

Here is the fun part. Turn on **airplane mode** - no wifi, no signal, nothing. Now ask it another question.

It still answers.

That is the whole point, made undeniable. There is no server on the other end. The AI is *on the phone itself*. With everything switched off, there is simply nowhere for your words to go, and it answers all the same.

## A few honest notes

- **It will be slower** than a laptop or a cloud app, and the small models are less clever. That is normal. You are running AI on a phone, which is a small miracle in itself.
- **Bigger models will struggle or refuse.** Stick to the 1B-2B range on a phone. If it gets hot or sluggish, pick a smaller one.
- **Your phone may already have one built in** (recent phones ship with a small on-device model), but the app above is the reliable way to try it yourself today, on almost any phone.

## If something looks wrong

- **The download is slow or seems stuck** - that is your wifi, not the app. It is a big file. Stay on wifi, keep the app open, and let it finish.
- **The app crashes, the model won't load, or the phone gets hot** - the model is too big for your phone. Delete it and pick a smaller one (aim for 1B).
- **You can't find the model I named** - model lists change often. Any small one labelled around 1B or 2B will do; the size matters more than the exact name.
- **Replies come slowly** - normal on a phone, especially an older one. A smaller model replies faster.

**What "working" looks like:** the download reaches 100%, the model loads, and a reply appears in the chat. The real proof is the airplane-mode test below.

## Wow, on a phone

You just ran an AI, offline, on the device in your pocket. A year ago most people would have told you that was impossible.

If you have not yet done it on a computer, that path is even simpler and the models are smarter - see [run your first model]({{< relref "run-your-first-model" >}}). And if you want to understand what you just ran, [what a local LLM is]({{< relref "what-is-a-local-llm" >}}) explains it in plain words.
