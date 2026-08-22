+++
title = "One door to all your models: LiteLLM"
date = 2026-05-31
weight = 13
authorship = "human-ai"
+++

Once you run more than one model, a small mess appears. This model lives in Ollama on one port. That one is served by vLLM on another. A third might be a cloud API. Every tool you own has to know where each model lives and how to talk to it. Change anything, and you are editing settings in five places.

[LiteLLM](https://github.com/BerriAI/litellm) fixes this by being a single front door. It puts *one* address, speaking *one* common language, in front of all your models - wherever they actually live.

## The idea in one picture

I run LiteLLM as a small always-on gateway. Everything on my machine talks to it, and it talks to the real engines behind the scenes:

```
  your apps / agents / scripts
            |
            |  one address, one API
            v
        LiteLLM  (:4000)
         /        \
        v          v
   Ollama         vLLM
   (:11434)       (:8000)
```

The "one language" is the OpenAI API format - the same shape almost every AI tool already speaks. So any app that can talk to OpenAI can talk to *your* models instead, just by pointing it at your gateway. It never needs to know that one model is Ollama and another is vLLM.

## What the setup actually looks like

The whole configuration is a list that maps a friendly name to a real model and where it lives:

```yaml
model_list:
  - model_name: my-chat-model          # the name your apps ask for
    litellm_params:
      model: ollama_chat/llama3.1:8b    # what it really is...
      api_base: http://localhost:11434  # ...and where it lives
  - model_name: my-big-model
    litellm_params:
      model: openai/qwen3.5-122b         # a vLLM model, OpenAI-style
      api_base: http://localhost:8000/v1
```

That is the trick in full. Add a line, and a new model appears to every tool at once. Move a model to a different engine, and you change one `api_base` here - not a setting in every app.

## Why it is worth it

- **Your tools stop caring where models live.** Ollama, vLLM, a cloud API - all identical from the outside.
- **You swap backends without touching clients.** Change the config, not the code.
- **One place to secure.** A single door is a single lock, instead of a dozen open ports for a dozen tools to find.

## The honest gotcha

A gateway's model list is a *claim*, not a fact. Mine once advertised nine models that had been deleted (every call to them failed), while five models I was actually running were missing from the list entirely. The gateway will happily promise a model that is not there.

Two things follow from that. First, after any change, check the list against what is truly running. Second - and this is the tie to how I serve big models - if a backend only runs *one* model at a time (as vLLM does on my box), then only that one answers. The others in the list return "not found" until you switch to them. The door is real; what is behind it still has to actually be home.

You do not need my number of models to want this. The moment you have *two* ways of running models - say Ollama plus one cloud key - a gateway earns its place:

- **Point every tool at one address.** Set it once, forget where models live.
- **Mix local and cloud behind the same door.** A private local model and a cloud one can sit side by side, chosen by name.
- **Remember the list is a promise, not a guarantee.** Reconcile it with reality whenever you change something.

It is the quietest piece of my stack, and the one that makes all the others feel like a single tidy thing instead of a pile of ports.
