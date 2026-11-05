+++
title = "From a phone to a desktop: what changes, and what doesn't"
date = 2026-11-04
weight = 7
description = "The same question at every size - will it fit? - and why the answer gets more expensive to get wrong as the machine gets bigger."
authorship = "human-ai"
+++

There is a gap on this site. One part of it shows you how to [run a model on your phone]({{< relref "run-a-model-on-your-phone" >}}) in a few taps. Another part is me rationing 119 gigabytes across four models at two in the morning. Nothing explains how you get from one to the other.

This is that piece.

If you take one thing from this post: **the question is the same at every size. Will it fit? What changes is what happens when the answer is no.**

## The question

Every machine that runs a model is answering one thing: is there room for this. A rough version of the maths works everywhere. Take the model's size in billions, multiply by about half a gigabyte, and that is roughly what the *weights* need at a normal quality setting. A 7-billion model wants somewhere near 4GB.

That is a floor rather than a total. The conversation needs room on top, and the better quality settings are bigger files. But as a first check, before you download anything, it is the number that tells you whether to bother.

That arithmetic does not change between a phone and a server. What changes is **where** that room has to come from, and what the machine does when it runs out.

{{< fig src="/image/posts/four-memory-shapes.svg" class="diagram" alt="Four machines and where a model has to fit: a phone, a laptop, a desktop with a separate graphics card, and a machine with unified memory. The consequence of not fitting gets worse down the list." caption="The same question four times. Only the last row can take the whole machine down with it." >}}

## Four sizes, four different "no"

**On a phone**, the room is your free storage and a slice of memory the operating system is willing to lend an app. You are looking at models around 1 to 2 billion, and about 2GB free. When it does not fit, the app refuses, or it loads and then dies. Annoying, and that is all. Nothing else on the phone notices.

**On a laptop with no separate graphics card**, the room is ordinary memory, the same memory everything else is using. Models up to about 7 or 8 billion are realistic. When it does not quite fit, nothing dramatic happens: the machine starts moving pieces to disk to cope, and everything crawls. You will think the model is slow. The model is fine. The machine is out of room.

**On a desktop with a graphics card**, something different happens. The card has its own separate memory, and it is usually much smaller than the computer's. Mine has 12GB on the card next to far more in the machine. The model has to fit in the card's 12, not in the machine's total, and that catches people out constantly. When it does not fit you get a clear error and the model refuses to load. The rest of the computer carries on, completely unbothered. The wall is hard, and the wall is *kind*.

**On a machine with unified memory**, there is no separate card memory. One pool, shared by the processor, the graphics side, and the operating system. This is how my main box works, and it is why a 122-billion model runs on something the size of a hardback. But the kind wall is gone with it. Ask for more than exists and you are not taking memory from the graphics card. You are taking it from the machine. [Mine hard-rebooted]({{< relref "one-machine-two-engines" >}}).

## The thing worth noticing

Read those four again and watch the consequence of being wrong.

On a phone, an app closes. On a laptop, things get slow. On a graphics card, you get a polite error. On unified memory, the computer falls over.

**The failure gets more expensive as the machine gets bigger.** That is backwards from what you would guess, and it is the honest reason the deeper posts on this site are so preoccupied with memory. It is not enthusiasm for numbers. It is that on a big shared-memory machine, getting the numbers wrong is not a model problem any more. It is a machine problem.

## Which numbers start to matter, and when

So the practical answer to "what changes as I move up" is: the list of things you have to know gets longer, one item at a time.

On a phone, you need the file size. That is it.

On a laptop, you need the file size and some idea of your free memory.

On a graphics card, you need the card's memory separately from the machine's, because only one of those two numbers is the one that counts.

On unified memory, you need all of that plus something nobody warns you about: [how much room the conversation itself takes]({{< relref "what-a-model-costs" >}}), which can be several times the size of the model. And if you care how fast it answers, you need [how many bytes it reads per word]({{< relref "bytes-per-token" >}}), which has almost nothing to do with the number in its name.

Each step up adds one thing to check. None of the earlier things stop being true.

---

- **Start where you are.** A phone running a 1-billion model is doing the real thing, not a toy version of it.
- **Learn the one piece of arithmetic.** Billions times roughly half a gigabyte, for the weights. It travels all the way up, and it is always a floor rather than the full bill.
- **Find out whether your machine has one pool of memory or two.** It changes everything else.
- **Expect the failures to get more expensive as the machine gets bigger**, not less.

If you want the full version of the question, [the four gates]({{< relref "the-four-gates" >}}) walks through every way a model can refuse to run, in the order you hit them. This post is the short route. That one is the map.
