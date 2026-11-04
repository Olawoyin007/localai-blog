+++
title = "I gave a talk about the plumbing"
date = 2026-10-16
weight = 12
description = "A talk at Community Over Code in Glasgow, about running local models as scheduled work, and the one question I could not answer."
authorship = "human-ai"
+++

In October I stood up at Community Over Code in Glasgow and talked for forty minutes about the subject of this site: running models on your own hardware, and the unglamorous work that keeps them running.

The session was in a track called AI Plumbers, which is a good name and partly why I submitted. The room filled with Apache Airflow contributors and committers, which is to say the people who maintain the thing I was describing. That was not the audience I had pictured.

The recording is on YouTube: [AI Plumbing: Orchestrating Local LLMs with Apache Airflow](https://www.youtube.com/watch?v=d2K-4Kr-a24). The [slides are here](/slides/ai-plumbing-glasgow-2026.pdf) if you would rather read than watch.

## What it was about

The same argument I keep making here. Running a model locally is the easy part. What costs you is everything around it: knowing whether the model is actually loaded, giving it a memory budget it cannot exceed, unloading it so the next thing can run, and noticing when something fails at three in the morning.

I showed how I run a nightly check on my own models as scheduled work rather than as a shell script, and what breaks when you do it on one machine where everything shares the same memory.

## The question I could not answer

Near the end, someone asked about an official Airflow component I had described as not covering the lifecycle problem. His point, roughly, was that I could still use it and let the retry mechanism handle a model that was not ready yet.

I did not have a clean answer in the moment and I did not argue. What I should have said, and what I worked out afterwards, is that there are three specific things that layer would need: knowing when a model is ready, being able to load and unload it, and checking whether the server behind it is alive at all.

The reply I got was better than the question deserved. They asked what I would want it to do. That is an invitation, and I have not finished taking it up.

## What I would change

The talk assumed one machine, because that is what I had. I have since split it: one box runs the models and another runs everything that decides when they should run. That separation turns out to be the interesting part, and it was barely a sentence in the version I gave.

---

If you are weighing up whether to submit a talk somewhere about work you do on your own hardware: the people who maintain the tools you use are more generous than you expect, and more interested in what broke than in what worked.
