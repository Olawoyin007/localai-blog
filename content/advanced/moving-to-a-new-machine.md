+++
title = "Moving a whole stack to a new machine"
date = 2026-04-26
weight = 16
authorship = "human-ai"
+++

When my old box had to be replaced, I did not just have files to copy. I had a whole running world to move: models, databases, background jobs, apps my day depends on. All of it living on one machine that was about to be gone.

Moving it taught me more than setting it up did. Here is what I would tell you before you move your own, so your day is calmer than my first one was.

## A migration is a checklist, not a vibe

The single best thing I did was refuse to do it from memory. I wrote a runbook first: every step, in order, with a command next to it. Dull, and exactly right. A migration is a sequence of small, boring, correct steps, and the moment you improvise in the middle of one is the moment something important quietly does not come across.

If you take nothing else from this: write the steps down before you touch anything.

## The order that actually works

Not the order you are excited about. The order things depend on:

1. **Foundations first** - storage mounted where it belongs, permissions and access sorted. The unglamorous plumbing everything else sits on.
2. **Then your data** - databases, app state, anything that holds your history.
3. **Then the services on top** - the models, the apps, the jobs.

Bring things up in the order they need each other, not the order you miss them. An app that starts before its database is just a faster way to see an error.

## The thing you cannot re-download

Here is the distinction that reorganised how I think about all of it.

**Models are reproducible.** Delete one, and you can pull it again tomorrow, byte for byte. They are big and annoying to move, but they are never *lost*.

**Your data is not.** Your documents, your notes, your app's history, your database - there is exactly one copy, and if the migration eats it, it is gone. So that is what you protect first and hardest. Back it up *before* you touch the old machine, not during the move.

And do not trust a backup you have not checked. Every time I restored a database, I counted the rows against what the old one had - "353 documents, 6,933 chunks." Either the numbers match, or they do not. "It restored without an error" is not the same as "it is all there."

## "It started" is not "it works"

At the end, the temptation is to see everything running and call it done. I have learned to spend the extra ten minutes going service by service and actually *using* each one. Ask the model a real question. Open the app and click something. Check the job ran.

A service can start cleanly and still be broken - pointing at the wrong data, missing a setting, quietly answering nonsense. The only honest test is to use it the way you actually use it.

## Keep your scars written down

My runbook has a section I am oddly proud of: the things that broke *last* time, and the fix for each. So the second migration simply skipped the trial-and-error of the first. Every painful hour I spent once became a single line I never had to relearn.

That list is worth more than the rest of the runbook combined. Your past self already paid for those lessons. Write them down so you only pay once.

You do not need a rack of services for any of this to matter. Even moving a single local setup to a new laptop, the same shape holds:

- **Write the steps down first.** Improvising mid-move is how things go missing.
- **Move in dependency order** - foundations, then data, then the things on top.
- **Back up what you cannot rebuild, and verify it landed.** Models come back; your data does not.
- **Test by using it, not by watching it start.**

A migration feels frightening because it looks like one huge leap. It is not. It is a list of small correct steps, and the calm comes entirely from having written the list before you needed it.
